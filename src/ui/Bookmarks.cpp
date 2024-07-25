#include <iostream>
#include <vector>
#include <algorithm>

class Bookmark {
public:
    std::string title;
    std::string url;
};

class Bookmarks {
private:
    std::vector<Bookmark> bookmarks;

public:
    void addBookmark(const std::string& title, const std::string& url) {
        Bookmark newBookmark{title, url};
        bookmarks.push_back(newBookmark);
    }

    void removeBookmark(const std::string& url) {
        bookmarks.erase(std::remove_if(bookmarks.begin(), bookmarks.end(),
            &url {
                return bookmark.url == url;
            }), bookmarks.end());
    }

    std::vector<Bookmark> getBookmarks() const {
        return bookmarks;
    }

    void displayBookmarks() const {
        for (const auto& bookmark : bookmarks) {
            std::cout << "Title: " << bookmark.title << ", URL: " << bookmark.url << std::endl;
        }
    }
};
