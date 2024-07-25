#include <iostream>
#include <string>
#include <vector>
#include <algorithm>

class AdBlocker {
public:
    bool isAd(const std::string& url) const {
        // Simple check for ad URLs
        return url.find("ads") != std::string::npos;
    }

    void blockAds(std::vector<std::string>& urls) const {
        urls.erase(std::remove_if(urls.begin(), urls.end(),
            this {
                return isAd(url);
            }), urls.end());
    }
};
