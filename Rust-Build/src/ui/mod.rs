pub mod navigation;
pub mod tab_manager;
pub mod settings;
pub mod bookmarks;
pub mod downloads;
pub mod theme;
pub mod ad_blocker;
pub mod extension_manager;
pub mod html_template;

use tab_manager::TabManager;
use bookmarks::BookmarkManager;
use downloads::DownloadManager;
use extension_manager::ExtensionManager;
use std::path::PathBuf;

pub struct Ui {
    pub tab_manager: TabManager,
    pub bookmark_manager: BookmarkManager,
    pub download_manager: DownloadManager,
    pub extension_manager: ExtensionManager,
}

impl Ui {
    pub fn new(download_dir: PathBuf, bookmarks_file: String, extensions_config: String) -> Self {
        Self {
            tab_manager: TabManager::new(),
            bookmark_manager: BookmarkManager::new(bookmarks_file),
            download_manager: DownloadManager::new(download_dir),
            extension_manager: ExtensionManager::new(extensions_config),
        }
    }

    pub fn init(&mut self) {
        // Initialize UI components
        self.tab_manager.init();
        // Add initialization for other components as needed
    }
}