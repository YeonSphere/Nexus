use std::collections::HashMap;
use serde::{Serialize, Deserialize};
use std::fs;
use std::path::Path;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Extension {
    pub id: String,
    pub name: String,
    pub version: String,
    pub enabled: bool,
}

pub struct ExtensionManager {
    extensions: HashMap<String, Extension>,
    config_path: String,
}

impl ExtensionManager {
    pub fn new(config_path: String) -> Self {
        let extensions = Self::load_extensions(&config_path).unwrap_or_default();
        Self {
            extensions,
            config_path,
        }
    }

    fn load_extensions(config_path: &str) -> Result<HashMap<String, Extension>, Box<dyn std::error::Error>> {
        let contents = fs::read_to_string(config_path)?;
        let extensions: HashMap<String, Extension> = serde_json::from_str(&contents)?;
        Ok(extensions)
    }

    fn save_extensions(&self) -> Result<(), Box<dyn std::error::Error>> {
        let json = serde_json::to_string(&self.extensions)?;
        fs::write(&self.config_path, json)?;
        Ok(())
    }

    pub fn install_extension(&mut self, id: String, name: String, version: String) -> Result<bool, Box<dyn std::error::Error>> {
        if !self.extensions.contains_key(&id) {
            let extension = Extension { id: id.clone(), name, version, enabled: true };
            self.extensions.insert(id, extension);
            self.save_extensions()?;
            Ok(true)
        } else {
            Ok(false)
        }
    }

    pub fn uninstall_extension(&mut self, id: &str) -> Result<Option<Extension>, Box<dyn std::error::Error>> {
        let extension = self.extensions.remove(id);
        self.save_extensions()?;
        Ok(extension)
    }

    pub fn enable_extension(&mut self, id: &str) -> Result<bool, Box<dyn std::error::Error>> {
        let result = self.extensions.get_mut(id).map_or(false, |extension| {
            extension.enabled = true;
            true
        });
        self.save_extensions()?;
        Ok(result)
    }

    pub fn disable_extension(&mut self, id: &str) -> Result<bool, Box<dyn std::error::Error>> {
        let result = self.extensions.get_mut(id).map_or(false, |extension| {
            extension.enabled = false;
            true
        });
        self.save_extensions()?;
        Ok(result)
    }

    pub fn get_extension(&self, id: &str) -> Option<&Extension> {
        self.extensions.get(id)
    }

    pub fn get_all_extensions(&self) -> Vec<&Extension> {
        self.extensions.values().collect()
    }

    pub fn get_enabled_extensions(&self) -> Vec<&Extension> {
        self.extensions.values().filter(|e| e.enabled).collect()
    }

    pub fn update_extension(&mut self, id: &str, new_version: String) -> Result<bool, Box<dyn std::error::Error>> {
        let result = self.extensions.get_mut(id).map_or(false, |extension| {
            extension.version = new_version;
            true
        });
        self.save_extensions()?;
        Ok(result)
    }
}
