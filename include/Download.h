#ifndef DOWNLOAD_H
#define DOWNLOAD_H

#include <string>
#include <vector>

class Download {
public:
    std::string fileName;
    std::string url;
    std::string status;

    Download(const std::string& fileName, const std::string& url, const std::string& status);
};

class Downloads {
private:
    std::vector<Download> downloads;

public:
    void addDownload(const std::string& fileName, const std::string& url);
    void updateDownloadStatus(const std::string& fileName, const std::string& status);
    std::vector<Download> getDownloads() const;
    void displayDownloads() const;
    void removeDownload(const std::string& fileName);
};

#endif // DOWNLOAD_H
