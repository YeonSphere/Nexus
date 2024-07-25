#ifndef ADBLOCKER_H
#define ADBLOCKER_H

#include <string>
#include <vector>

class AdBlocker {
public:
    bool isAd(const std::string& url) const;
    void blockAds(std::vector<std::string>& urls) const;
};

#endif // ADBLOCKER_H
