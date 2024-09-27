use std::collections::HashMap;
use serde::{Serialize, Deserialize};
use chrono::{DateTime, Utc};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Bookmark {
    pub url: String,
    pub title: String,
    pub folder: Option<String>,
    pub created_at: DateTime<Utc>,
    pub last_visited: Option<DateTime<Utc>>,
}

pub struct BookmarkManager {
    bookmarks: HashMap<String, Bookmark>,
}

impl BookmarkManager {
    pub fn new() -> Self {
        BookmarkManager {
            bookmarks: HashMap::new(),
        }
    }

    pub fn add_bookmark(&mut self, url: String, title: String, folder: Option<String>) -> &Bookmark {
        self.bookmarks.entry(url.clone()).or_insert_with(|| Bookmark {
            url,
            title,
            folder,
            created_at: Utc::now(),
            last_visited: None,
        });
        self.bookmarks.get(&url).unwrap()
    }

    pub fn remove_bookmark(&mut self, url: &str) -> Option<Bookmark> {
        self.bookmarks.remove(url)
    }

    pub fn get_bookmark(&self, url: &str) -> Option<&Bookmark> {
        self.bookmarks.get(url)
    }

    pub fn update_bookmark(&mut self, url: &str, new_title: Option<String>, new_folder: Option<String>) -> Option<&Bookmark> {
        self.bookmarks.get_mut(url).map(|bookmark| {
            if let Some(title) = new_title {
                bookmark.title = title;
            }
            bookmark.folder = new_folder;
            bookmark
        })
    }

    pub fn get_all_bookmarks(&self) -> Vec<&Bookmark> {
        self.bookmarks.values().collect()
    }

    pub fn get_bookmarks_by_folder(&self, folder: &str) -> Vec<&Bookmark> {
        self.bookmarks.values()
            .filter(|b| b.folder.as_deref() == Some(folder))
            .collect()
    }

    pub fn update_last_visited(&mut self, url: &str) -> Option<&Bookmark> {
        self.bookmarks.get_mut(url).map(|bookmark| {
            bookmark.last_visited = Some(Utc::now());
            bookmark
        })
    }

    pub fn get_recent_bookmarks(&self, limit: usize) -> Vec<&Bookmark> {
        let mut bookmarks: Vec<&Bookmark> = self.bookmarks.values().collect();
        bookmarks.sort_by(|a, b| b.last_visited.cmp(&a.last_visited));
        bookmarks.into_iter().take(limit).collect()
    }
}
