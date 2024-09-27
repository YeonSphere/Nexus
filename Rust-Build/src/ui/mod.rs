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
        Self {
            tab_manager: TabManager::new(),
        }
    }

    pub fn init(&mut self) {
        // Initialize UI components
        self.tab_manager.init();
        // Add initialization for other components as needed
    }
}