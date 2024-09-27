use flutter_rust_bridge::*;
use crate::ui::settings::Settings as AppSettings;
use crate::ui::navigation::Navigation;
use crate::ui::tab_manager::TabManager;

#[flutter_rust_bridge::frb(dart_decl)]
pub mod api {
    use super::*;

    pub struct Settings {
        pub ad_blocking_enabled: bool,
        pub default_search_engine: String,
        pub homepage: String,
    }

    pub fn get_settings() -> Settings {
        let app_settings = AppSettings::load().unwrap_or_else(|_| AppSettings::new());
        Settings {
            ad_blocking_enabled: app_settings.ad_blocking_enabled,
            default_search_engine: app_settings.default_search_engine,
            homepage: app_settings.homepage,
        }
    }

    pub fn set_settings(settings: Settings) {
        let mut app_settings = AppSettings::new();
        app_settings.ad_blocking_enabled = settings.ad_blocking_enabled;
        app_settings.default_search_engine = settings.default_search_engine;
        app_settings.homepage = settings.homepage;
        app_settings.save().unwrap_or_else(|e| {
            eprintln!("Failed to save settings: {}", e);
        });
    }
    }

    pub fn initialize_browser() {
        let tab_manager = TabManager::new();
        let mut navigation = Navigation::new(tab_manager);
        navigation.initialize_ad_blocker().unwrap_or_else(|e| eprintln!("Failed to initialize ad blocker: {}", e));
        println!("Browser initialized successfully");
    }

    pub fn navigate_to_url(url: String) {
        let mut tab_manager = TabManager::new();
        let mut navigation = Navigation::new(tab_manager);
        navigation.navigate_to(&url);
        println!("Navigated to: {}", url);
    }
}
