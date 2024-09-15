mod ui;
mod renderer;

use wry::{
    application::{
        event::{Event, StartCause, WindowEvent},
        event_loop::{ControlFlow, EventLoop},
        window::WindowBuilder,
        keyboard::{PhysicalKey, KeyCode},
        event::{KeyEvent, ElementState},
    },
    webview::WebViewBuilder,
};

use ui::{TabManager, Navigation};
use crate::renderer::Renderer;
use ui::theme::Theme;

#[cfg(feature = "dev")]
use env_logger;

fn main() -> wry::Result<()> {
    #[cfg(feature = "dev")]
    env_logger::init();

    log::info!("Starting Nexus Browser");

    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_title("Nexus Browser")
        .with_inner_size(wry::application::dpi::LogicalSize::new(1024.0, 768.0))
        .build(&event_loop)?;

    let theme = Theme::dark();
    theme.apply_to_window(&window);

    let mut tab_manager = TabManager::new();
    let mut navigation = Navigation::new(tab_manager);

    // Create the initial tab
    match navigation.tab_manager.create_tab(&window, "https://www.example.com") {
        Ok(_) => log::info!("Initial tab created"),
        Err(e) => log::error!("Failed to create initial tab: {}", e),
    }

    // Create a simple UI with themed HTML
    let html_content = format!(
        r#"
        <!DOCTYPE html>
        <html>
        <head>
            <style>
            {}
            </style>
        </head>
        <body>
            <h1>Nexus Browser</h1>
            <input id='url' type='text' placeholder='Enter URL'>
            <button onclick='navigate()'>Go</button>
            <script>
                function navigate() {{
                    window.location.href = document.getElementById("url").value;
                }}
            </script>
        </body>
        </html>
        "#,
        theme.get_css()
    );

    let webview = WebViewBuilder::new(window)?
        .with_url(&format!("data:text/html,{}", html_content))?
        .with_initialization_script("window.external.invoke = (s) => window.location.href = s;")
        .build()?;

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
                event: WindowEvent::KeyboardInput {
                    event: KeyEvent {
                        physical_key: PhysicalKey::Code(key_code),
                        state: ElementState::Pressed,
                        ..
                    },
                    ..
                },
                ..
            } => {
                match key_code {
                    KeyCode::KeyR => {
                        log::info!("Refreshing page");
                        navigation.refresh();
                    },
                    KeyCode::Backspace => {
                        log::info!("Navigating back");
                        navigation.go_back();
                    },
                    KeyCode::BracketRight => {
                        log::info!("Navigating forward");
                        navigation.go_forward();
                    },
                    _ => {}
                }
            }
            _ => (),
        }
    });

    // Example usage:
    let html = "<html><body><h1>Hello, World!</h1></body></html>";
    let css = "h1 { color: blue; }";
    let rendered = renderer.render(html, css);
    println!("Rendered output:\n{}", rendered);
}