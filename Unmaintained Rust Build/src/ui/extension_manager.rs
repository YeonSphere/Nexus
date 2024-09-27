use std::collections::HashMap;

#[derive(Clone, Debug)]
pub struct Extension {
    pub id: String,
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

    pub fn install_extension(&mut self, id: String, name: String, version: String) -> bool {
        if !self.extensions.contains_key(&id) {
            let extension = Extension { id: id.clone(), name, version, enabled: true };
            self.extensions.insert(id, extension);
            true
        } else {
            false
        }
    }

    pub fn uninstall_extension(&mut self, id: &str) -> Option<Extension> {
        self.extensions.remove(id)
    }

    pub fn enable_extension(&mut self, id: &str) -> bool {
        if let Some(extension) = self.extensions.get_mut(id) {
            extension.enabled = true;
            true
        } else {
            false
        }
    }

    pub fn disable_extension(&mut self, id: &str) -> bool {
        if let Some(extension) = self.extensions.get_mut(id) {
            extension.enabled = false;
            true
        } else {
            false
        }
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
}
