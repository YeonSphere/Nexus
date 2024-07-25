#ifndef SETTINGS_H
#define SETTINGS_H

#include <string>
#include <unordered_map>

class Settings {
private:
    std::unordered_map<std::string, std::string> settings;

public:
    Settings();
    void setSetting(const std::string& key, const std::string& value);
    std::string getSetting(const std::string& key) const;
    void displaySettingsMenu() const;
    void changeSearchEngine(const std::string& engine);
    void resetToDefault();
};

#endif // SETTINGS_H
