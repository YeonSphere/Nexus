#ifndef TABMANAGER_H
#define TABMANAGER_H

#include <string>
#include <vector>

class Tab {
public:
    std::string title;
    std::string url;

    Tab(const std::string& title, const std::string& url);
};

class TabManager {
private:
    std::vector<Tab> tabs;
    int currentTabIndex;

public:
    TabManager();
    void openTab(const std::string& url);
    void closeTab(int index);
    void switchToTab(int index);
    Tab getCurrentTab() const;
    void displayTabs() const;
    void updateTabTitle(int index, const std::string& title);
};

#endif // TABMANAGER_H
