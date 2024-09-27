use crate::ui::TabManager;
use crate::ui::ad_blocker::AdBlocker;

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
        if let Some(tab) = self.tab_manager.get_active_tab_mut() {
            tab.webview.evaluate_script("history.back()").unwrap_or_else(|e| log::error!("Failed to go back: {}", e));
        }
    }

    pub fn go_forward(&mut self) {
        if let Some(tab) = self.tab_manager.get_active_tab_mut() {
            tab.webview.evaluate_script("history.forward()").unwrap_or_else(|e| log::error!("Failed to go forward: {}", e));
        }
    }

    pub fn refresh(&mut self) {
        if let Some(tab) = self.tab_manager.get_active_tab_mut() {
            tab.webview.evaluate_script("location.reload()").unwrap_or_else(|e| log::error!("Failed to refresh: {}", e));
        }
    }

    pub fn navigate_to(&mut self, url: &str) {
        if self.ad_blocker.should_block(url) {
            log::info!("Blocked request to: {}", url);
            return;
        }
        let id = self.tab_manager.get_active_tab().map(|tab| tab.id).unwrap_or(0);
        if let Some(tab) = self.tab_manager.get_active_tab_mut() {
            tab.webview.load_url(url);
            self.tab_manager.update_tab_url(id, url.to_string());
        }
    }

    pub fn get_current_url(&self) -> Option<String> {
        self.tab_manager.get_active_tab().map(|tab| tab.url.clone())
    }

    pub fn initialize_ad_blocker(&mut self) -> Result<(), Box<dyn std::error::Error>> {
        self.ad_blocker.load_filter_lists()?;
        self.ad_blocker.set_enabled(true);
        Ok(())
    }

    pub fn toggle_settings(&mut self) {
        if let Some(tab) = self.tab_manager.get_active_tab_mut() {
            tab.webview.evaluate_script("toggleSettings()").unwrap_or_else(|e| log::error!("Failed to toggle settings: {}", e));
        }
    }

    pub fn toggle_dev_tools(&mut self) {
        if let Some(tab) = self.tab_manager.get_active_tab_mut() {
            tab.webview.evaluate_script("toggleDevTools()").unwrap_or_else(|e| log::error!("Failed to toggle dev tools: {}", e));
        }
    }
}