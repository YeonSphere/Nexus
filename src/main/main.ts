import { app, BrowserWindow, ipcMain, session } from 'electron';
import * as path from 'path';
import { setupAdBlocker, AdBlocker } from '../utils/adBlocker';
import { setupFingerPrintResistance } from '../utils/fingerPrintResistance';
import { setupSleepingTabs } from '../utils/sleepingTabs';
import { getSettings, setSettings } from '../utils/settings';
import { setupSettingsHandlers } from '../utils/settings';

// Function to create the main browser window
function createWindow(): BrowserWindow {
  const mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      webviewTag: true,
      preload: path.join(__dirname, 'preload.js')
    }
  });

  mainWindow.webContents.session.webRequest.onHeadersReceived((details, callback) => {
    callback({
      responseHeaders: {
        ...details.responseHeaders,
        'Content-Security-Policy': "default-src 'self' 'unsafe-inline' 'unsafe-eval' data: https:"
      }
    });
  });

  mainWindow.loadFile(path.join(__dirname, '..', '..', 'public', 'index.html'));
  mainWindow.webContents.openDevTools();
  return mainWindow;
}

function setupContentSecurityPolicy(window: BrowserWindow): void {
  window.webContents.session.webRequest.onHeadersReceived((details, callback) => {
    callback({
      responseHeaders: {
        ...details.responseHeaders,
        'Content-Security-Policy': [
          "default-src 'self' https: data: 'unsafe-inline' 'unsafe-eval';" +
          "script-src 'self' 'unsafe-eval' 'unsafe-inline';" +
          "style-src 'self' 'unsafe-inline';" +
          "img-src 'self' data: https:;" +
          "connect-src 'self' https:;" +
          "font-src 'self';" +
          "object-src 'none';" +
          "base-uri 'self';" +
          "form-action 'self';" +
          "frame-src 'self' https:;" +
          "child-src 'self' https:;" +
          "upgrade-insecure-requests"
        ].join('')
      }
    });
  });
}

function setupBrowserFeatures(window: BrowserWindow): void {
  const adBlocker = new AdBlocker();
  setupAdBlocker(session.defaultSession, adBlocker);
  setupFingerPrintResistance(window);
  setupSleepingTabs(window);
}

app.whenReady().then(() => {
  setupSettingsHandlers();
  const mainWindow = createWindow();
  setupContentSecurityPolicy(mainWindow);
  setupBrowserFeatures(mainWindow);

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

// IPC Handlers
ipcMain.handle('navigate-to-url', (event, url) => {
  const focusedWindow = BrowserWindow.getFocusedWindow();
  if (focusedWindow) {
    focusedWindow.loadURL(url);
  } else {
    console.error('No focused window found');
  }
});

// Error handling
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  app.quit();
});
