mod ui;
mod renderer;
mod bridge_generated;
mod network;
mod state;
mod security;
mod theme;
mod tab_manager;
mod settings;
mod bookmarks;
mod downloads;
mod extension_manager;

use flutter_rust_bridge::frb;
use crate::bridge_generated::api::*;
use tokio::runtime::Runtime;

#[cfg(feature = "dev")]
use env_logger;

#[frb]
pub fn init_app() {
    #[cfg(feature = "dev")]
    env_logger::init();

    log::info!("Starting Nexus Browser");
}

#[frb]
pub fn run_browser() -> Result<(), Box<dyn std::error::Error>> {
    let rt = Runtime::new()?;
    let _guard = rt.enter();

    rt.block_on(async {
        let settings = settings::Settings::load().unwrap_or_else(|_| settings::Settings::new());
        let theme = if settings.dark_mode {
            theme::Theme::dark()
        } else {
            theme::Theme::light()
        };

        ui::initialize(&settings, &theme).await?;
        renderer::setup(&settings).await?;
        network::initialize(&settings).await?;
        security::setup(&settings).await?;
        
        let tab_manager = tab_manager::TabManager::new(settings.clone());
        let bookmark_manager = bookmarks::BookmarkManager::new();
        let download_manager = downloads::DownloadManager::new();
        let extension_manager = extension_manager::ExtensionManager::new();

        state::initialize(settings, tab_manager, bookmark_manager, download_manager, extension_manager).await?;

        log::info!("Browser initialized successfully");
        Ok(())
    })
}