use std::collections::HashMap;

#[derive(Clone, Debug)]
pub struct Bookmark {
    pub url: String,
    pub title: String,
    pub folder: Option<String>,
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

    pub fn add_bookmark(&mut self, url: String, title: String, folder: Option<String>) {
        let bookmark = Bookmark { url: url.clone(), title, folder };
        self.bookmarks.insert(url, bookmark);
    }

    pub fn remove_bookmark(&mut self, url: &str) -> Option<Bookmark> {
        self.bookmarks.remove(url)
    }

    pub fn get_bookmark(&self, url: &str) -> Option<&Bookmark> {
        self.bookmarks.get(url)
    }

    pub fn update_bookmark(&mut self, url: &str, new_title: String, new_folder: Option<String>) -> bool {
        if let Some(bookmark) = self.bookmarks.get_mut(url) {
            bookmark.title = new_title;
            bookmark.folder = new_folder;
            true
        } else {
            false
        }
    }

    pub fn get_all_bookmarks(&self) -> Vec<&Bookmark> {
        self.bookmarks.values().collect()
    }

    pub fn get_bookmarks_by_folder(&self, folder: &str) -> Vec<&Bookmark> {
        self.bookmarks.values()
            .filter(|b| b.folder.as_deref() == Some(folder))
            .collect()
    }
}
