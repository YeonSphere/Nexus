use std::collections::HashMap;

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
        ExtensionManager {
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

    pub fn remove_extension(&mut self, name: &str) {
        self.extensions.remove(name);
    }

    pub fn toggle_extension(&mut self, name: &str) -> bool {
        if let Some(extension) = self.extensions.get_mut(name) {
            extension.enabled = !extension.enabled;
            extension.enabled
        } else {
            false
        }
    }
}
