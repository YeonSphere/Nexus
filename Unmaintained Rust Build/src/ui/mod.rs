pub mod navigation;
pub mod tab_manager;
pub mod settings;
pub mod bookmarks;
pub mod downloads;
pub mod theme;
pub mod ad_blocker;
pub mod extension_manager;

use tab_manager::TabManager;

pub struct Ui {
    pub tab_manager: TabManager,
}

impl Ui {
    pub fn new() -> Self {
        Ui {
            tab_manager: TabManager::new(),
        }
    }

    pub fn init(&self) {
        // Initialize UI components
    }
}