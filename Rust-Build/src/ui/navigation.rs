use crate::ui::TabManager;
use crate::ui::ad_blocker::AdBlocker;
use crate::ui::bookmarks::BookmarkManager;
use crate::ui::downloads::DownloadManager;
use crate::ui::extension_manager::ExtensionManager;
use log;
use std::error::Error;

pub struct Navigation {
    pub tab_manager: TabManager,
    pub ad_blocker: AdBlocker,
    pub bookmark_manager: BookmarkManager,
    pub download_manager: DownloadManager,
    pub extension_manager: ExtensionManager,
}

impl Navigation {
    pub fn new(
        tab_manager: TabManager,
        bookmark_manager: BookmarkManager,
        download_manager: DownloadManager,
        extension_manager: ExtensionManager,
    ) -> Self {
        Navigation {
            tab_manager,
            ad_blocker: AdBlocker::new(),
            bookmark_manager,
            download_manager,
            extension_manager,
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

    pub fn add_bookmark(&mut self, url: &str, title: &str) -> Result<(), Box<dyn Error>> {
        self.bookmark_manager.add_bookmark(url.to_string(), title.to_string())
    }

    pub fn start_download(&mut self, url: &str, file_name: &str) -> Result<(), Box<dyn Error>> {
        let download_id = self.download_manager.add_download(url.to_string(), file_name.to_string());
        self.download_manager.start_download(download_id).await
    }

    pub fn install_extension(&mut self, id: &str, name: &str, version: &str) -> Result<bool, Box<dyn Error>> {
        self.extension_manager.install_extension(id.to_string(), name.to_string(), version.to_string())
    }
}