use std::collections::HashMap;

// TODO: Implement AUR integration for extension installation

pub struct Extension {
    pub name: String,
    pub version: String,
    pub enabled: bool,
}

pub struct ExtensionManager {
    extensions: HashMap<String, Extension>,
}

impl ExtensionManager {
    pub fn new() -> Self {
        Self {
            extensions: HashMap::new(),
        }
    }

    pub fn add_extension(&mut self, name: String, version: String) {
        let extension = Extension {
            name: name.clone(),
            version,
            enabled: true,
        };
        self.extensions.insert(name, extension);
    }

    pub fn remove_extension(&mut self, name: &str) -> Option<Extension> {
        self.extensions.remove(name)
    }

    pub fn toggle_extension(&mut self, name: &str) -> Option<bool> {
        self.extensions.get_mut(name).map(|extension| {
            extension.enabled = !extension.enabled;
            extension.enabled
        })
    }

    pub fn get_extension(&self, name: &str) -> Option<&Extension> {
        self.extensions.get(name)
    }

    pub fn list_extensions(&self) -> Vec<&Extension> {
        self.extensions.values().collect()
    }
}
