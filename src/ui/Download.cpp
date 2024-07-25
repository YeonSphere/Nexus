#include "Download.h"
#include <iostream>
#include <algorithm>

Download::Download(const std::string& fileName, const std::string& url, const std::string& status)
    : fileName(fileName), url(url), status(status) {}

void Downloads::addDownload(const std::string& fileName, const std::string& url) {
    downloads.emplace_back(fileName, url, "In Progress");
}

void Downloads::updateDownloadStatus(const std::string& fileName, const std::string& status) {
    auto it = std::find_if(downloads.begin(), downloads.end(),
        &fileName {
            return download.fileName == fileName;
        });
    if (it != downloads.end()) {
        it->status = status;
    }
}

std::vector<Download> Downloads::getDownloads() const {
    return downloads;
}

void Downloads::displayDownloads() const {
    for (const auto& download : downloads) {
        std::cout << "File: " << download.fileName << ", URL: " << download.url
                  << ", Status: " << download.status << std::endl;
    }
}

void Downloads::removeDownload(const std::string& fileName) {
    downloads.erase(std::remove_if(downloads.begin(), downloads.end(),
        &fileName {
            return download.fileName == fileName;
        }), downloads.end());
}
