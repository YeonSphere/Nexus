mod ui;
mod renderer;

use wry::{
    application::{
        event::{Event, StartCause, WindowEvent},
        event_loop::{ControlFlow, EventLoop},
        window::WindowBuilder,
        keyboard::Key,
    },
    webview::WebViewBuilder,
};

use crate::ui::navigation::Navigation;
use crate::ui::tab_manager::TabManager;
use crate::renderer::Renderer;
use ui::theme::Theme;
use serde_json;

#[cfg(feature = "dev")]
use env_logger;

fn main() -> wry::Result<()> {
    #[cfg(feature = "dev")]
    env_logger::init();

    log::info!("Starting Nexus Browser");

    let event_loop = EventLoop::new()?;
    let window = WindowBuilder::new()
        .with_title("Nexus Browser")
        .with_inner_size(wry::application::dpi::LogicalSize::new(1024.0, 768.0))
        .build(&event_loop)?;

    let theme = Theme::dark();
    theme.apply_to_window(&window);

    let tab_manager = TabManager::new();
    let mut navigation = Navigation::new(tab_manager);

    // Create the initial tab with a basic browser UI
    let html_content = format!(
        r#"
        <!DOCTYPE html>
        <html>
        <head>
            <style>
            {}
            body {{
                display: flex;
                flex-direction: column;
                height: 100vh;
                margin: 0;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: #f0f0f0;
            }}
            #browser-ui {{
                display: flex;
                padding: 10px;
                background-color: #ffffff;
                align-items: center;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }}
            #content {{
                flex-grow: 1;
                border: none;
            }}
            .button {{
                padding: 8px 12px;
                margin: 0 5px;
                border: none;
                background-color: transparent;
                color: #5f6368;
                cursor: pointer;
                border-radius: 4px;
                transition: background-color 0.2s;
            }}
            .button:hover {{
                background-color: #f1f3f4;
            }}
            #url-bar {{
                flex-grow: 1;
                margin: 0 10px;
                padding: 8px 12px;
                border: 1px solid #dfe1e5;
                border-radius: 24px;
                font-size: 14px;
            }}
            #url-bar:focus {{
                outline: none;
                box-shadow: 0 0 0 2px #4285f4;
            }}
            #settings-panel, #devtools-panel {{
                display: none;
                position: absolute;
                top: 60px;
                right: 10px;
                background-color: white;
                border-radius: 8px;
                padding: 16px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }}
            </style>
        </head>
        <body>
            <div id="browser-ui">
                <button class="button" onclick="history.back()">&#8592;</button>
                <button class="button" onclick="history.forward()">&#8594;</button>
                <button class="button" onclick="location.reload()">&#8635;</button>
                <input id="url-bar" type="text" value="https://yeonsphere.github.io/">
                <button class="button" onclick="navigate()">Go</button>
                <button class="button" onclick="toggleSettings()">&#9881;</button>
                <button class="button" onclick="toggleDevTools()">&#128295;</button>
            </div>
            <div id="settings-panel">
                <h2>Settings</h2>
                <label><input type="checkbox" id="adblock-toggle"> Enable Ad Blocking</label>
                <button onclick="saveSettings()">Save</button>
            </div>
            <div id="devtools-panel">
                <h2>DevTools</h2>
                <textarea id="console" readonly></textarea>
                <input type="text" id="console-input" placeholder="Enter JavaScript...">
                <button onclick="executeConsole()">Execute</button>
            </div>
            <iframe id="content" src="https://yeonsphere.github.io/"></iframe>
            <script>
            function navigate() {{
                const url = document.getElementById('url-bar').value;
                document.getElementById('content').src = url;
            }}

            function toggleSettings() {{
                const settings = document.getElementById('settings-panel');
                settings.style.display = settings.style.display === 'none' ? 'block' : 'none';
            }}

            function toggleDevTools() {{
                const devtools = document.getElementById('devtools-panel');
                devtools.style.display = devtools.style.display === 'none' ? 'block' : 'none';
            }}

            function saveSettings() {{
                const adblockEnabled = document.getElementById('adblock-toggle').checked;
                window.ipc.postMessage(JSON.stringify({{ type: 'updateSettings', adblockEnabled }}));
            }}

            function executeConsole() {{
                const input = document.getElementById('console-input').value;
                try {{
                    const result = eval(input);
                    document.getElementById('console').value += `> ${{input}}\n${{result}}\n`;
                }} catch (error) {{
                    document.getElementById('console').value += `> ${{input}}\n${{error}}\n`;
                }}
                document.getElementById('console-input').value = '';
            }}

            // Keyboard shortcuts
            document.addEventListener('keydown', (e) => {{
                if (e.ctrlKey && e.key === 'i') {{
                    toggleDevTools();
                }} else if (e.ctrlKey && e.key === ',') {{
                    toggleSettings();
                }}
            }});
            </script>
        </body>
        </html>
        "#,
        theme.get_css()
    );

    let webview = WebViewBuilder::new(window)?
        .with_url(&format!("data:text/html,{}", html_content))?
        .with_ipc_handler(move |_, message| {
            if let Ok(data) = serde_json::from_str::<serde_json::Value>(&message) {
                if let Some(msg_type) = data["type"].as_str() {
                    match msg_type {
                        "updateSettings" => {
                            if let Some(adblock_enabled) = data["adblockEnabled"].as_bool() {
                                navigation.ad_blocker.set_enabled(adblock_enabled);
                            }
                        }
                        _ => {}
                    }
                }
            }
        })
        .build()?;

    navigation.tab_manager.add_tab(webview);

    log::info!("Initial tab created");

    navigation.initialize_ad_blocker();

    let renderer = Renderer::new();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::NewEvents(StartCause::Init) => log::info!("Nexus Browser has started!"),
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => *control_flow = ControlFlow::Exit,
            Event::WindowEvent {
                event: WindowEvent::KeyboardInput { input, .. },
                ..
            } => {
                if let Some(key) = input.virtual_keycode {
                    match key {
                        Key::R => {
                            log::info!("Refreshing page");
                            navigation.refresh();
                        },
                        Key::Back => {
                            log::info!("Navigating back");
                            navigation.go_back();
                        },
                        Key::BracketRight => {
                            log::info!("Navigating forward");
                            navigation.go_forward();
                        },
                        Key::Return => {
                            if let Some(tab) = navigation.tab_manager.get_active_tab_mut() {
                                tab.webview.evaluate_script("navigate()").ok();
                            }
                        },
                        Key::I if input.modifiers.ctrl() => {
                            log::info!("Toggling DevTools");
                            navigation.toggle_dev_tools();
                        },
                        Key::Comma if input.modifiers.ctrl() => {
                            log::info!("Toggling Settings");
                            navigation.toggle_settings();
                        },
                        _ => {}
                    }
                }
            }
            _ => (),
        }
    })?;

    Ok(())
}