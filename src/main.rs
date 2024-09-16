mod ui;
mod renderer;

use wry::{
    application::{
        event::{Event, StartCause, WindowEvent},
        event_loop::{ControlFlow, EventLoop},
        window::WindowBuilder,
        keyboard::KeyCode,
        event::{KeyEvent, ElementState},
    },
    application::keyboard::Key,
};

use crate::ui::navigation::Navigation;
use crate::ui::tab_manager::TabManager;
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
    match navigation.tab_manager.create_tab(window, "https://yeonsphere.github.io/") {
        Ok(_) => log::info!("Initial tab created"),
        Err(e) => log::error!("Failed to create initial tab: {}", e),
    }

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
                        logical_key,
                        state: ElementState::Pressed,
                        ..
                    },
                    ..
                },
                ..
            } => {
                match logical_key {
                    Key::Character("r") => {
                        log::info!("Refreshing page");
                        navigation.refresh();
                    },
                    Key::Backspace => {
                        log::info!("Navigating back");
                        navigation.go_back();
                    },
                    Key::Character("]") => {
                        log::info!("Navigating forward");
                        navigation.go_forward();
                    },
                    _ => {}
                }
            }
            _ => (),
        }
    });
}