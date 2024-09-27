import { contextBridge, ipcRenderer } from 'electron';

contextBridge.exposeInMainWorld('api', {
  getSettings: () => ipcRenderer.invoke('get-settings'),
  setSettings: (settings: any) => ipcRenderer.invoke('set-settings', settings),
  navigateToUrl: (url: string) => ipcRenderer.invoke('navigate-to-url', url),
});
