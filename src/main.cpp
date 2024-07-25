#include <iostream>
#include "renderer/Renderer.h"
#include "ui/Navigation.h"
#include "ui/TabManager.h"
#include "ui/Settings.h"
#include "ui/Bookmarks.h"
#include "ui/Downloads.h"
#include "AdBlocker.h"
#include "AIEngine.h"
#include "ExtensionManager.h"

void displayMenu() {
    std::cout << "1. Open Tab\n";
    std::cout << "2. Close Tab\n";
    std::cout << "3. Switch Tab\n";
    std::cout << "4. Go Forward\n";
    std::cout << "5. Go Back\n";
    std::cout << "6. Refresh\n";
    std::cout << "7. Go Home\n";
    std::cout << "8. Settings\n";
    std::cout << "9. Bookmarks\n";
    std::cout << "10. Downloads\n";
    std::cout << "11. Exit\n";
}

int main() {
    HTMLParser htmlParser;
    CSSParser cssParser;
    Renderer renderer;
    Navigation navigation;
    TabManager tabManager;
    Settings settings;
    Bookmarks bookmarks;
    Downloads downloads;
    AdBlocker adBlocker;
    AIEngine aiEngine;
    ExtensionManager extensionManager;

    settings.displaySettingsMenu();

    bool running = true;
    while (running) {
        displayMenu();
        int choice;
        std::cin >> choice;

        switch (choice) {
            case 1: {
                std::string url;
                std::cout << "Enter URL: ";
                std::cin >> url;
                tabManager.openTab(url);
                break;
            }
            case 2: {
                int index;
                std::cout << "Enter tab index to close: ";
                std::cin >> index;
                tabManager.closeTab(index);
                break;
            }
            case 3: {
                int index;
                std::cout << "Enter tab index to switch to: ";
                std::cin >> index;
                tabManager.switchToTab(index);
                break;
            }
            case 4:
                navigation.goForward();
                break;
            case 5:
                navigation.goBack();
                break;
            case 6:
                navigation.refresh();
                break;
            case 7:
                navigation.goHome();
                break;
            case 8: {
                settings.displaySettingsMenu();
                std::string engine;
                std::cout << "Enter search engine (Qwant, Bing, Google, Naver): ";
                std::cin >> engine;
                settings.changeSearchEngine(engine);
                break;
            }
            case 9: {
                std::string title, url;
                std::cout << "Enter bookmark title: ";
                std::cin >> title;
                std::cout << "Enter bookmark URL: ";
                std::cin >> url;
                bookmarks.addBookmark(title, url);
                break;
            }
            case 10: {
                std::string fileName, url;
                std::cout << "Enter file name: ";
                std::cin >> fileName;
                std::cout << "Enter download URL: ";
                std::cin >> url;
                downloads.addDownload(fileName, url);
                break;
            }
            case 11:
                running = false;
                break;
            default:
                std::cout << "Invalid choice. Please try again.\n";
                break;
        }
    }

    return 0;
}
