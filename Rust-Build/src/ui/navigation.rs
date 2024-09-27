use crate::ui::TabManager;
use crate::ui::ad_blocker::AdBlocker;
use log;
use std::error::Error;

pub struct Navigation {
    pub tab_manager: TabManager,
    pub ad_blocker: AdBlocker,
}

impl Navigation {
    pub fn new(tab_manager: TabManager) -> Self {
        Navigation {
            tab_manager,
            ad_blocker: AdBlocker::new(),
        }
    }

    pub fn go_back(&mut self) {
        self.execute_script("history.back()", "Failed to go back")
    }

    pub fn go_forward(&mut self) {
        self.execute_script("history.forward()", "Failed to go forward")
    }

    pub fn refresh(&mut self) {
        self.execute_script("location.reload()", "Failed to refresh")
    }

    pub fn navigate_to(&mut self, url: &str) {
        if self.ad_blocker.should_block(url) {
            log::info!("Blocked request to: {}", url);
            return;
        }
        if let Some(tab) = self.tab_manager.get_active_tab_mut() {
            tab.webview.load_url(url);
            self.tab_manager.update_tab_url(tab.id, url.to_string());
        }
    }

    pub fn get_current_url(&self) -> Option<String> {
        self.tab_manager.get_active_tab().map(|tab| tab.url.clone())
    }

    pub fn initialize_ad_blocker(&mut self) -> Result<(), Box<dyn Error>> {
        self.ad_blocker.load_filter_lists()?;
        self.ad_blocker.set_enabled(true);
        Ok(())
    }

    pub fn toggle_settings(&mut self) {
        self.execute_script("toggleSettings()", "Failed to toggle settings")
    }

    pub fn toggle_dev_tools(&mut self) {
        self.execute_script("toggleDevTools()", "Failed to toggle dev tools")
    }

    fn execute_script(&mut self, script: &str, error_msg: &str) {
        if let Some(tab) = self.tab_manager.get_active_tab_mut() {
            tab.webview.evaluate_script(script)
                .unwrap_or_else(|e| log::error!("{}: {}", error_msg, e));
        }
    }
}