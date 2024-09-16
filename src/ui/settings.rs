use serde::{Deserialize, Serialize};

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
            default_search_engine: "https://www.google.com/search?q=".to_string(),
            homepage: "https://yeonsphere.github.io/".to_string(),
        }
    }

    pub fn save(&self) -> Result<(), Box<dyn std::error::Error>> {
        // Implement saving settings to a file
        Ok(())
    }

    pub fn load() -> Result<Self, Box<dyn std::error::Error>> {
        // Implement loading settings from a file
        Ok(Self::new())
    }
}
