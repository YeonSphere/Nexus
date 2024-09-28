use flutter_rust_bridge::*;
use crate::ui::settings::Settings as AppSettings;
use crate::ui::navigation::Navigation;
use crate::ui::tab_manager::TabManager;
use crate::ui::bookmarks::BookmarkManager;
use crate::ui::downloads::DownloadManager;
use crate::ui::extension_manager::ExtensionManager;

#[flutter_rust_bridge::frb(dart_decl)]
pub mod api {
    use super::*;

    pub struct Settings {
        pub ad_blocking_enabled: bool,
        pub default_search_engine: String,
        pub homepage: String,
        pub dark_mode: bool,
        pub font_size: u8,
        pub enable_javascript: bool,
        pub enable_cookies: bool,
    }

    pub fn get_settings() -> Settings {
        let app_settings = AppSettings::load().unwrap_or_else(|_| AppSettings::new());
        Settings {
            ad_blocking_enabled: app_settings.ad_blocking_enabled,
            default_search_engine: app_settings.default_search_engine,
            homepage: app_settings.homepage,
            dark_mode: app_settings.dark_mode,
            font_size: app_settings.font_size,
            enable_javascript: app_settings.enable_javascript,
            enable_cookies: app_settings.enable_cookies,
        }
    }

    pub fn set_settings(settings: Settings) {
        let mut app_settings = AppSettings::new();
        app_settings.ad_blocking_enabled = settings.ad_blocking_enabled;
        app_settings.default_search_engine = settings.default_search_engine;
        app_settings.homepage = settings.homepage;
        app_settings.dark_mode = settings.dark_mode;
        app_settings.font_size = settings.font_size;
        app_settings.enable_javascript = settings.enable_javascript;
        app_settings.enable_cookies = settings.enable_cookies;
        app_settings.save().unwrap_or_else(|e| {
            eprintln!("Failed to save settings: {}", e);
        });
    }

    pub fn initialize_browser() -> Result<(), Box<dyn std::error::Error>> {
        let settings = AppSettings::load().unwrap_or_else(|_| AppSettings::new());
        let tab_manager = TabManager::new(settings.clone());
        let bookmark_manager = BookmarkManager::new();
        let download_manager = DownloadManager::new();
        let extension_manager = ExtensionManager::new();
        let mut navigation = Navigation::new(tab_manager, bookmark_manager, download_manager, extension_manager);
        navigation.ad_blocker.initialize()?;
        println!("Browser initialized successfully");
        Ok(())
    }

    pub fn navigate_to_url(url: String) -> Result<(), Box<dyn std::error::Error>> {
        let settings = AppSettings::load().unwrap_or_else(|_| AppSettings::new());
        let tab_manager = TabManager::new(settings.clone());
        let bookmark_manager = BookmarkManager::new();
        let download_manager = DownloadManager::new();
        let extension_manager = ExtensionManager::new();
        let mut navigation = Navigation::new(tab_manager, bookmark_manager, download_manager, extension_manager);
        navigation.navigate_to(&url);
        println!("Navigated to: {}", url);
        Ok(())
    }
}
