use serde::{Deserialize, Serialize};
use std::path::PathBuf;

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
        let mut path = if let Some(project_dirs) = directories::ProjectDirs::from("com", "YeonSphere", "Nexus") {
            project_dirs.config_dir().to_path_buf()
        } else {
            PathBuf::from("~/.config/nexus")
        };
        path.push("settings.json");
        path
    }

    pub fn save(&self) -> Result<(), Box<dyn std::error::Error>> {
        let config_file = Self::get_config_dir();
        std::fs::create_dir_all(config_file.parent().unwrap())?;
        let json = serde_json::to_string_pretty(self)?;
        std::fs::write(config_file, json)?;
        Ok(())
    }

    pub fn load() -> Result<Self, Box<dyn std::error::Error>> {
        let config_file = Self::get_config_dir();
        if config_file.exists() {
            let json = std::fs::read_to_string(config_file)?;
            Ok(serde_json::from_str(&json)?)
        } else {
            Ok(Self::new())
        }
    }
}
