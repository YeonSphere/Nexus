use crate::ui::TabManager;

pub struct Navigation {
    tab_manager: TabManager,
}

impl Navigation {
    pub fn new(tab_manager: TabManager) -> Self {
        Navigation { tab_manager }
    }

    pub fn go_back(&mut self) {
        if let Some(tab) = self.tab_manager.get_active_tab_mut() {
            tab.webview.evaluate_script("history.back()").ok();
        }
    }

    pub fn go_forward(&mut self) {
        if let Some(tab) = self.tab_manager.get_active_tab_mut() {
            tab.webview.evaluate_script("history.forward()").ok();
        }
    }

    pub fn refresh(&mut self) {
        if let Some(tab) = self.tab_manager.get_active_tab_mut() {
            tab.webview.evaluate_script("location.reload()").ok();
        }
    }

    pub fn navigate_to(&mut self, url: &str) {
        let id = self.tab_manager.get_active_tab().map(|tab| tab.id).unwrap_or(0);
        if let Some(tab) = self.tab_manager.get_active_tab_mut() {
            tab.webview.load_url(url);
        }
        self.tab_manager.update_tab_url(id, url.to_string());
    }

    pub fn get_current_url(&self) -> Option<String> {
        self.tab_manager.get_active_tab().map(|tab| tab.url.clone())
    }
}