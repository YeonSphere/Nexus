import { DownloadManager } from './types';
import { downloadFile } from './fileUtils';
import { updateProgress } from './progressUtils';

const downloadManager: DownloadManager = {
    queue: [],
    activeDownloads: 0,
    maxConcurrentDownloads: 3,

    addToQueue(url: string, destination: string) {
        this.queue.push({ url, destination });
        this.processQueue();
    },

    processQueue() {
        while (this.activeDownloads < this.maxConcurrentDownloads && this.queue.length > 0) {
            const download = this.queue.shift();
            if (download) {
                this.startDownload(download.url, download.destination);
            }
        }
    },

    async startDownload(url: string, destination: string) {
        this.activeDownloads++;
        try {
            await downloadFile(url, destination, (progress) => {
                updateProgress(url, progress);
            });
        } catch (error) {
            console.error(`Error downloading ${url}:`, error);
        } finally {
            this.activeDownloads--;
            this.processQueue();
        }
    },
};

export default downloadManager;
