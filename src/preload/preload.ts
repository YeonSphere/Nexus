import { contextBridge, ipcRenderer } from 'electron';

contextBridge.exposeInMainWorld('api', {
  getSettings: () => ipcRenderer.invoke('get-settings'),
  setSettings: (settings: unknown) => ipcRenderer.invoke('set-settings', settings),
  navigateToUrl: (url: string) => ipcRenderer.invoke('navigate-to-url', url),
  onTabSleep: (callback: () => void) => {
    const listener = () => callback();
    ipcRenderer.on('tab-sleep', listener);
    return () => ipcRenderer.removeListener('tab-sleep', listener);
  },
  // Add new methods for tab management
  createTab: (url: string) => ipcRenderer.invoke('create-tab', url),
  closeTab: (tabId: number) => ipcRenderer.invoke('close-tab', tabId),
  switchTab: (tabId: number) => ipcRenderer.invoke('switch-tab', tabId),
  // Add methods for bookmark management
  addBookmark: (url: string, title: string) => ipcRenderer.invoke('add-bookmark', url, title),
  removeBookmark: (id: string) => ipcRenderer.invoke('remove-bookmark', id),
  getBookmarks: () => ipcRenderer.invoke('get-bookmarks'),
  // Add methods for download management
  startDownload: (url: string) => ipcRenderer.invoke('start-download', url),
  pauseDownload: (downloadId: string) => ipcRenderer.invoke('pause-download', downloadId),
  resumeDownload: (downloadId: string) => ipcRenderer.invoke('resume-download', downloadId),
  cancelDownload: (downloadId: string) => ipcRenderer.invoke('cancel-download', downloadId),
  // Add methods for extension management
  installExtension: (extensionId: string) => ipcRenderer.invoke('install-extension', extensionId),
  uninstallExtension: (extensionId: string) => ipcRenderer.invoke('uninstall-extension', extensionId),
  getInstalledExtensions: () => ipcRenderer.invoke('get-installed-extensions'),
  // Add method for theme management
  setTheme: (isDarkMode: boolean) => ipcRenderer.invoke('set-theme', isDarkMode),
  aiAnalyzeCurrentPage: (content: string) => ipcRenderer.invoke('ai-analyze-current-page', content),
});
