use std::path::PathBuf;
use std::sync::{Arc, Mutex};
use tokio::sync::mpsc;
use reqwest;
use tokio::fs::File;
use tokio::io::AsyncWriteExt;

#[derive(Clone, Debug)]
pub struct Download {
    pub id: usize,
    pub url: String,
    pub file_name: String,
    pub progress: f32,
    pub status: DownloadStatus,
    pub destination: PathBuf,
}

#[derive(Clone, Debug)]
pub enum DownloadStatus {
    Pending,
    InProgress,
    Completed,
    Failed(String),
    Cancelled,
}

pub struct DownloadManager {
    downloads: Arc<Mutex<Vec<Download>>>,
    download_dir: PathBuf,
    next_id: usize,
    tx: mpsc::Sender<DownloadMessage>,
}

enum DownloadMessage {
    Start(usize),
    Cancel(usize),
    UpdateProgress(usize, f32),
    Complete(usize),
    Fail(usize, String),
}

impl DownloadManager {
    pub fn new(download_dir: PathBuf) -> Self {
        let (tx, mut rx) = mpsc::channel(100);
        let downloads = Arc::new(Mutex::new(Vec::new()));
        let downloads_clone = Arc::clone(&downloads);

        tokio::spawn(async move {
            while let Some(msg) = rx.recv().await {
                let mut downloads = downloads_clone.lock().unwrap();
                match msg {
                    DownloadMessage::Start(id) => {
                        if let Some(download) = downloads.iter_mut().find(|d| d.id == id) {
                            download.status = DownloadStatus::InProgress;
                        }
                    }
                    DownloadMessage::Cancel(id) => {
                        if let Some(download) = downloads.iter_mut().find(|d| d.id == id) {
                            download.status = DownloadStatus::Cancelled;
                        }
                    }
                    DownloadMessage::UpdateProgress(id, progress) => {
                        if let Some(download) = downloads.iter_mut().find(|d| d.id == id) {
                            download.progress = progress;
                        }
                    }
                    DownloadMessage::Complete(id) => {
                        if let Some(download) = downloads.iter_mut().find(|d| d.id == id) {
                            download.status = DownloadStatus::Completed;
                            download.progress = 100.0;
                        }
                    }
                    DownloadMessage::Fail(id, error) => {
                        if let Some(download) = downloads.iter_mut().find(|d| d.id == id) {
                            download.status = DownloadStatus::Failed(error);
                        }
                    }
                }
            }
        });

        DownloadManager {
            downloads,
            download_dir,
            next_id: 0,
            tx,
        }
    }

    pub fn add_download(&mut self, url: String, file_name: String) -> usize {
        let id = self.next_id;
        self.next_id += 1;

        let download = Download {
            id,
            url,
            file_name: file_name.clone(),
            progress: 0.0,
            status: DownloadStatus::Pending,
            destination: self.download_dir.join(file_name),
        };

        self.downloads.lock().unwrap().push(download);
        id
    }

    pub async fn start_download(&self, id: usize) {
        self.tx.send(DownloadMessage::Start(id)).await.ok();
        
        let downloads = self.downloads.lock().unwrap();
        if let Some(download) = downloads.iter().find(|d| d.id == id) {
            let url = download.url.clone();
            let destination = download.destination.clone();
            let tx = self.tx.clone();

            tokio::spawn(async move {
                match reqwest::get(&url).await {
                    Ok(response) => {
                        if let Ok(mut file) = File::create(&destination).await {
                            let total_size = response.content_length().unwrap_or(0);
                            let mut downloaded = 0;
                            let mut stream = response.bytes_stream();

                            while let Some(item) = stream.next().await {
                                if let Ok(chunk) = item {
                                    if file.write_all(&chunk).await.is_err() {
                                        tx.send(DownloadMessage::Fail(id, "Failed to write file".to_string())).await.ok();
                                        return;
                                    }
                                    downloaded += chunk.len() as u64;
                                    let progress = (downloaded as f32 / total_size as f32) * 100.0;
                                    tx.send(DownloadMessage::UpdateProgress(id, progress)).await.ok();
                                }
                            }
                            tx.send(DownloadMessage::Complete(id)).await.ok();
                        } else {
                            tx.send(DownloadMessage::Fail(id, "Failed to create file".to_string())).await.ok();
                        }
                    }
                    Err(e) => {
                        tx.send(DownloadMessage::Fail(id, format!("Download failed: {}", e))).await.ok();
                    }
                }
            });
        }
    }

    pub fn cancel_download(&self, id: usize) {
        self.tx.try_send(DownloadMessage::Cancel(id)).ok();
    }

    pub fn get_downloads(&self) -> Vec<Download> {
        self.downloads.lock().unwrap().clone()
    }

    pub fn update_progress(&self, id: usize, progress: f32) {
        self.tx.try_send(DownloadMessage::UpdateProgress(id, progress)).ok();
    }

    pub fn complete_download(&self, id: usize) {
        self.tx.try_send(DownloadMessage::Complete(id)).ok();
    }

    pub fn fail_download(&self, id: usize, error: String) {
        self.tx.try_send(DownloadMessage::Fail(id, error)).ok();
    }
}
