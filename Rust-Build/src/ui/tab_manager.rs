use std::collections::HashMap;
use wry::webview::{WebView, WebViewBuilder};
use wry::application::window::Window;
use crate::ui::settings::Settings;

pub struct Tab {
    pub id: usize,
    pub url: String,
    pub webview: WebView,
    pub title: String,
}

pub struct TabManager {
    tabs: HashMap<usize, Tab>,
    active_tab: Option<usize>,
    next_id: usize,
    settings: Settings,
}

impl TabManager {
    pub fn new(settings: Settings) -> Self {
        TabManager {
            tabs: HashMap::new(),
            active_tab: None,
            next_id: 0,
            settings,
        }
    }

    pub fn create_tab(&mut self, window: &Window, url: &str) -> wry::Result<usize> {
        let id = self.next_id;
        self.next_id += 1;

        let mut webview_builder = WebViewBuilder::new(window)
            .with_url(url)?;

        // Apply settings
        webview_builder = webview_builder
            .with_initialization_script(&format!("document.body.style.fontSize = '{}px';", self.settings.font_size))
            .with_javascript_enabled(self.settings.enable_javascript);

        if self.settings.dark_mode {
            webview_builder = webview_builder.with_initialization_script(
                "document.body.style.backgroundColor = 'black'; document.body.style.color = 'white';"
            );
        }

        let webview = webview_builder.build()?;

        let tab = Tab {
            id,
            webview,
            url: url.to_string(),
            title: String::new(),
        };

        self.tabs.insert(id, tab);
        self.active_tab = Some(id);
        Ok(id)
    }

    pub fn close_tab(&mut self, id: usize) {
        self.tabs.remove(&id);
        if self.active_tab == Some(id) {
            self.active_tab = self.tabs.keys().next().copied();
        }
    }

    pub fn set_active_tab(&mut self, id: usize) {
        if self.tabs.contains_key(&id) {
            self.active_tab = Some(id);
        }
    }

    pub fn get_active_tab(&self) -> Option<&Tab> {
        self.active_tab.and_then(|id| self.tabs.get(&id))
    }

    pub fn get_active_tab_mut(&mut self) -> Option<&mut Tab> {
        self.active_tab.and_then(move |id| self.tabs.get_mut(&id))
    }

    pub fn update_tab_title(&mut self, id: usize, title: String) {
        if let Some(tab) = self.tabs.get_mut(&id) {
            tab.title = title;
        }
    }

    pub fn update_tab_url(&mut self, id: usize, url: String) {
        if let Some(tab) = self.tabs.get_mut(&id) {
            tab.url = url;
        }
    }

    pub fn get_all_tabs(&self) -> Vec<&Tab> {
        self.tabs.values().collect()
    }

    pub fn add_tab(&mut self, webview: WebView) -> usize {
        let id = self.next_id;
        self.next_id += 1;

        let tab = Tab {
            id,
            webview,
            url: String::new(),
            title: String::new(),
        };

        self.tabs.insert(id, tab);
        self.active_tab = Some(id);
        id
    }

    pub fn update_settings(&mut self, new_settings: Settings) {
        self.settings = new_settings;
        // Apply new settings to all existing tabs
        for tab in self.tabs.values_mut() {
            tab.webview.evaluate_script(&format!("document.body.style.fontSize = '{}px';", self.settings.font_size)).ok();
            tab.webview.evaluate_script(&format!("document.body.style.backgroundColor = '{}'; document.body.style.color = '{}';",
                if self.settings.dark_mode { "black" } else { "white" },
                if self.settings.dark_mode { "white" } else { "black" }
            )).ok();
        }
    }
}
