#ifndef EXTENSIONMANAGER_H
#define EXTENSIONMANAGER_H

#include <string>
#include <unordered_map>

class Extension {
public:
    std::string name;
    std::string path;

    Extension(const std::string& name, const std::string& path);
};

class ExtensionManager {
private:
    std::unordered_map<std::string, Extension> extensions;

public:
    void loadExtension(const std::string& name, const std::string& path);
    void unloadExtension(const std::string& name);
    void listExtensions() const;
};

#endif // EXTENSIONMANAGER_H
