#include "Navigation.h"
#include <iostream>

void Navigation::goForward() {
    if (!forwardStack.empty()) {
        history.push(currentPage);
        currentPage = forwardStack.top();
        forwardStack.pop();
    } else {
        std::cout << "No forward history available.\n";
    }
}

void Navigation::goBack() {
    if (!history.empty()) {
        forwardStack.push(currentPage);
        currentPage = history.top();
        history.pop();
    } else {
        std::cout << "No back history available.\n";
    }
}

void Navigation::refresh() {
    std::cout << "Refreshing: " << currentPage << "\n";
}

void Navigation::goHome() {
    while (!history.empty()) history.pop();
    while (!forwardStack.empty()) forwardStack.pop();
    currentPage = "home";
    std::cout << "Navigated to home.\n";
}

void Navigation::navigateTo(const std::string& url) {
    if (!currentPage.empty()) {
        history.push(currentPage);
    }
    currentPage = url;
    while (!forwardStack.empty()) forwardStack.pop();
    std::cout << "Navigated to: " << url << "\n";
}

void Navigation::displayHistory() const {
    std::stack<std::string> temp = history;
    std::cout << "History:\n";
    while (!temp.empty()) {
        std::cout << temp.top() << "\n";
        temp.pop();
    }
}
