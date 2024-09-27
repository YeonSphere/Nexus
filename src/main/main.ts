import { app, BrowserWindow, ipcMain, session } from 'electron';
import * as path from 'path';
import { setupAdBlocker } from '../utils/adBlocker';
import { setupFingerPrintResistance } from '../utils/fingerPrintResistance';
import { setupSleepingTabs } from '../utils/sleepingTabs';
import { AdBlocker } from '../utils/adBlocker';

// Function to create the main browser window
function createWindow() {
  const mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, '../preload/preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      webviewTag: true,
    },
  });

  mainWindow.webContents.session.webRequest.onHeadersReceived((details, callback) => {
    callback({
      responseHeaders: {
        ...details.responseHeaders,
        'Content-Security-Policy': "default-src 'self'; script-src 'self'"
      }
    })
  });

  // Setup various browser features
  const adBlocker = new AdBlocker();
  setupAdBlocker(session.defaultSession, adBlocker); // Initialize ad blocker
  setupFingerPrintResistance(mainWindow); // Setup fingerprint resistance
  setupSleepingTabs(mainWindow); // Setup sleeping tabs feature

  // Load the main HTML file
  mainWindow.loadFile(path.join(__dirname, '../../public/index.html'));
}

// Create window when Electron has finished initialization
app.whenReady().then(() => {
  createWindow();

  // On macOS, recreate a window when dock icon is clicked
  app.on('activate', function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

// Quit the app when all windows are closed (except on macOS)
app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit();
});

// Handle IPC calls from renderer process

// Get settings
ipcMain.handle('get-settings', () => {
  // TODO: Implement actual settings retrieval from a configuration file or database
  return { 
    adBlockEnabled: true,
    fingerPrintResistanceEnabled: true,
    sleepingTabsEnabled: true,
  };
});

// Set settings
ipcMain.handle('set-settings', (event, settings) => {
  // TODO: Implement actual settings update to a configuration file or database
  console.log('Settings updated:', settings);
});

// Navigate to URL
ipcMain.handle('navigate-to-url', (event, url) => {
  const focusedWindow = BrowserWindow.getFocusedWindow();
  if (focusedWindow) {
    focusedWindow.loadURL(url);
  } else {
    console.error('No focused window found');
  }
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  app.quit();
});
