#ifndef NAVIGATION_H
#define NAVIGATION_H

#include <string>
#include <stack>

class Navigation {
private:
    std::stack<std::string> history;
    std::stack<std::string> forwardStack;
    std::string currentPage;

public:
    void goForward();
    void goBack();
    void refresh();
    void goHome();
    void navigateTo(const std::string& url);
    void displayHistory() const;
};

#endif // NAVIGATION_H
