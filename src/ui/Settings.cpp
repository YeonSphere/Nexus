#include "settings.h"
#include <iostream>

Settings::Settings() {
    // Initialize default settings
    settings["searchEngine"] = "Qwant";
    settings["theme"] = "Nebula Purple";
    settings["font"] = "Handwriting-Regular.otf";
}

void Settings::setSetting(const std::string& key, const std::string& value) {
    settings[key] = value;
}

std::string Settings::getSetting(const std::string& key) const {
    auto it = settings.find(key);
    if (it != settings.end()) {
        return it->second;
    } else {
        return "Setting not found";
    }
}

void Settings::displaySettingsMenu() const {
    std::cout << "Settings Menu:\n";
    for (const auto& setting : settings) {
        std::cout << setting.first << ": " << setting.second << "\n";
    }
}

void Settings::changeSearchEngine(const std::string& engine) {
    if (engine == "Qwant" || engine == "Google" || engine == "Naver" || engine == "Bing") {
        setSetting("searchEngine", engine);
        std::cout << "Search engine changed to: " << engine << "\n";
    } else {
        std::cout << "Invalid search engine. Available options: Qwant, Google, Naver, Bing.\n";
    }
}

void Settings::resetToDefault() {
    settings.clear();
    settings["searchEngine"] = "Qwant";
    settings["theme"] = "Nebula Purple";
    settings["font"] = "Handwriting-Regular.otf";
    std::cout << "Settings reset to default.\n";
}
