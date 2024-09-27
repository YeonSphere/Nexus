import { app, BrowserWindow, ipcMain } from 'electron';
import * as path from 'path';

function createWindow() {
  const mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, '../preload/preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  mainWindow.loadFile(path.join(__dirname, '../../public/index.html'));
}

app.whenReady().then(() => {
  createWindow();

  app.on('activate', function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit();
});

ipcMain.handle('get-settings', () => {
  // Implement settings retrieval
  return { adBlockEnabled: true };
});

ipcMain.handle('set-settings', (event, settings) => {
  // Implement settings update
  console.log('Settings updated:', settings);
});

ipcMain.handle('navigate-to-url', (event, url) => {
  // Implement navigation logic
  console.log('Navigating to:', url);
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  app.quit();
});
