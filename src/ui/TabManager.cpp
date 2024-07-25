#include "TabManager.h"
#include <iostream>
#include <algorithm>

Tab::Tab(const std::string& title, const std::string& url) : title(title), url(url) {}

TabManager::TabManager() : currentTabIndex(-1) {}

void TabManager::openTab(const std::string& url) {
    std::string title = "New Tab";
    tabs.emplace_back(title, url);
    currentTabIndex = tabs.size() - 1;
}

void TabManager::closeTab(int index) {
    if (index >= 0 && index < tabs.size()) {
        tabs.erase(tabs.begin() + index);
        if (currentTabIndex >= index) {
            currentTabIndex = std::max(0, currentTabIndex - 1);
        }
    } else {
        std::cerr << "Invalid tab index.\n";
    }
}

void TabManager::switchToTab(int index) {
    if (index >= 0 && index < tabs.size()) {
        currentTabIndex = index;
    } else {
        std::cerr << "Invalid tab index.\n";
    }
}

Tab TabManager::getCurrentTab() const {
    if (currentTabIndex >= 0 && currentTabIndex < tabs.size()) {
        return tabs[currentTabIndex];
    }
    return Tab("No Tab", "");
}

void TabManager::displayTabs() const {
    for (size_t i = 0; i < tabs.size(); ++i) {
        std::cout << (i == currentTabIndex ? "-> " : "   ") << "Title: " << tabs[i].title << ", URL: " << tabs[i].url << std::endl;
    }
}

void TabManager::updateTabTitle(int index, const std::string& title) {
    if (index >= 0 && index < tabs.size()) {
        tabs[index].title = title;
    } else {
        std::cerr << "Invalid tab index.\n";
    }
}
