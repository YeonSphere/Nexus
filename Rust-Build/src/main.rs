mod ui;
mod renderer;
mod bridge_generated;

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
        // TODO: Implement browser initialization and UI setup
        ui::initialize().await?;
        renderer::setup().await?;
        log::info!("Browser UI initialized");
        Ok(())
    })
}