use std::collections::HashMap;
use serde::{Serialize, Deserialize};
use chrono::{DateTime, Utc};
use std::fs;
use std::path::Path;

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
    file_path: String,
}

impl BookmarkManager {
    pub fn new(file_path: String) -> Self {
        let bookmarks = Self::load_bookmarks(&file_path).unwrap_or_default();
        BookmarkManager {
            bookmarks,
            file_path,
        }
    }

    fn load_bookmarks(file_path: &str) -> Result<HashMap<String, Bookmark>, Box<dyn std::error::Error>> {
        let contents = fs::read_to_string(file_path)?;
        let bookmarks: HashMap<String, Bookmark> = serde_json::from_str(&contents)?;
        Ok(bookmarks)
    }

    fn save_bookmarks(&self) -> Result<(), Box<dyn std::error::Error>> {
        let json = serde_json::to_string(&self.bookmarks)?;
        fs::write(&self.file_path, json)?;
        Ok(())
    }

    pub fn add_bookmark(&mut self, url: String, title: String, folder: Option<String>) -> Result<&Bookmark, Box<dyn std::error::Error>> {
        let bookmark = Bookmark {
            url: url.clone(),
            title,
            folder,
            created_at: Utc::now(),
            last_visited: None,
        };
        self.bookmarks.insert(url.clone(), bookmark);
        self.save_bookmarks()?;
        Ok(self.bookmarks.get(&url).unwrap())
    }

    pub fn remove_bookmark(&mut self, url: &str) -> Result<Option<Bookmark>, Box<dyn std::error::Error>> {
        let bookmark = self.bookmarks.remove(url);
        self.save_bookmarks()?;
        Ok(bookmark)
    }

    pub fn get_bookmark(&self, url: &str) -> Option<&Bookmark> {
        self.bookmarks.get(url)
    }

    pub fn update_bookmark(&mut self, url: &str, new_title: Option<String>, new_folder: Option<String>) -> Result<Option<&Bookmark>, Box<dyn std::error::Error>> {
        let result = self.bookmarks.get_mut(url).map(|bookmark| {
            if let Some(title) = new_title {
                bookmark.title = title;
            }
            bookmark.folder = new_folder;
            bookmark
        });
        self.save_bookmarks()?;
        Ok(result)
    }

    pub fn get_all_bookmarks(&self) -> Vec<&Bookmark> {
        self.bookmarks.values().collect()
    }

    pub fn get_bookmarks_by_folder(&self, folder: &str) -> Vec<&Bookmark> {
        self.bookmarks.values()
            .filter(|b| b.folder.as_deref() == Some(folder))
            .collect()
    }

    pub fn update_last_visited(&mut self, url: &str) -> Result<Option<&Bookmark>, Box<dyn std::error::Error>> {
        let result = self.bookmarks.get_mut(url).map(|bookmark| {
            bookmark.last_visited = Some(Utc::now());
            bookmark
        });
        self.save_bookmarks()?;
        Ok(result)
    }

    pub fn get_recent_bookmarks(&self, limit: usize) -> Vec<&Bookmark> {
        let mut bookmarks: Vec<&Bookmark> = self.bookmarks.values().collect();
        bookmarks.sort_by(|a, b| b.last_visited.cmp(&a.last_visited));
        bookmarks.into_iter().take(limit).collect()
    }
}
