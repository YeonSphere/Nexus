use std::collections::HashMap;
use wry::webview::{WebView, WebViewBuilder};
use wry::application::window::Window;

pub struct Tab {
    pub id: usize,
    pub url: String,
    pub webview: WebView,
    title: String,
}

pub struct TabManager {
    tabs: HashMap<usize, Tab>,
    active_tab: usize,
    next_id: usize,
}

impl TabManager {
    pub fn new() -> Self {
        TabManager {
            tabs: HashMap::new(),
            active_tab: 0,
            next_id: 0,
        }
    }

    pub fn create_tab(&mut self, window: &Window, url: &str) -> wry::Result<usize> {
        let id = self.next_id;
        self.next_id += 1;

        let webview = WebViewBuilder::new(window.to_owned())?
            .with_url(url)?
            .build()?;

        let tab = Tab {
            id,
            webview,
            url: url.to_string(),
            title: String::new(),
        };

        self.tabs.insert(id, tab);
        self.active_tab = id;
        Ok(id)
    }

    pub fn close_tab(&mut self, id: usize) {
        self.tabs.remove(&id);
        if self.active_tab == id {
            self.active_tab = *self.tabs.keys().next().unwrap_or(&0);
        }
    }

    pub fn set_active_tab(&mut self, id: usize) {
        if self.tabs.contains_key(&id) {
            self.active_tab = id;
        }
    }

    pub fn get_active_tab(&self) -> Option<&Tab> {
        self.tabs.get(&self.active_tab)
    }

    pub fn get_active_tab_mut(&mut self) -> Option<&mut Tab> {
        self.tabs.get_mut(&self.active_tab)
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
}
