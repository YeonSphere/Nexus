use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use std::fs;
use std::io;

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Settings {
    pub ad_blocking_enabled: bool,
    pub default_search_engine: String,
    pub homepage: String,
}

impl Settings {
    pub fn new() -> Self {
        Settings {
            ad_blocking_enabled: true,
            default_search_engine: "https://search.brave.com/search?q=".to_string(),
            homepage: "https://yeonsphere.github.io/".to_string(),
        }
    }

    pub fn available_search_engines() -> Vec<(&'static str, &'static str)> {
        vec![
            ("Brave", "https://search.brave.com/search?q="),
            ("Searx", "https://searx.be/search?q="),
            ("Google", "https://www.google.com/search?q="),
            ("Bing", "https://www.bing.com/search?q="),
            ("Naver", "https://search.naver.com/search.naver?query="),
        ]
    }

    fn get_config_dir() -> PathBuf {
        directories::ProjectDirs::from("com", "YeonSphere", "Nexus")
            .map(|dirs| dirs.config_dir().to_path_buf())
            .unwrap_or_else(|| {
                let home = std::env::var("HOME").unwrap_or_else(|_| String::from("~"));
                PathBuf::from(home).join(".config").join("nexus")
            })
            .join("settings.json")
    }

    pub fn save(&self) -> Result<(), io::Error> {
        let config_file = Self::get_config_dir();
        match config_file.parent() {
            Some(parent) => {
                fs::create_dir_all(parent)?;
                let json = serde_json::to_string_pretty(self)
                    .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;
                fs::write(config_file, json)
            },
            None => Err(io::Error::new(io::ErrorKind::InvalidInput, "Invalid config file path: parent directory does not exist"))
        }
    }

    pub fn load() -> Result<Self, io::Error> {
        let config_file = Self::get_config_dir();
        if config_file.exists() {
            let json = fs::read_to_string(config_file)?;
            serde_json::from_str(&json)
                .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))
        } else {
            Ok(Self::new())
        }
    }
}
