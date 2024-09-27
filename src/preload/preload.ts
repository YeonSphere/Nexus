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
});
