#include "ExtensionManager.h"
#include <iostream>

Extension::Extension(const std::string& name, const std::string& path)
    : name(name), path(path) {}

void ExtensionManager::loadExtension(const std::string& name, const std::string& path) {
    extensions[name] = Extension(name, path);
    std::cout << "Loading extension: " << name << " from: " << path << std::endl;
}

void ExtensionManager::unloadExtension(const std::string& name) {
    auto it = extensions.find(name);
    if (it != extensions.end()) {
        extensions.erase(it);
        std::cout << "Unloading extension: " << name << std::endl;
    } else {
        std::cout << "Extension not found: " << name << std::endl;
    }
}

void ExtensionManager::listExtensions() const {
    std::cout << "Loaded Extensions:" << std::endl;
    for (const auto& pair : extensions) {
        std::cout << "Name: " << pair.second.name << ", Path: " << pair.second.path << std::endl;
    }
}
