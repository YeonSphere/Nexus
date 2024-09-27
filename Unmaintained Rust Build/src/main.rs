mod ui;
mod renderer;
mod bridge_generated;

use flutter_rust_bridge::frb;
use crate::bridge_generated::api::*;

#[cfg(feature = "dev")]
use env_logger;

#[frb]
pub fn init_app() {
    #[cfg(feature = "dev")]
    env_logger::init();

    log::info!("Starting Nexus Browser");
}

#[frb]
pub fn run_browser() {
    let rt = Runtime::new().unwrap();
    let _guard = rt.enter();

    rt.block_on(async {
        // TODO: Implement browser initialization and UI setup
        log::info!("Browser UI initialized");
    });
}