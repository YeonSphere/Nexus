import { app, BrowserWindow, ipcMain, session } from 'electron';
import * as path from 'path';
import { setupAdBlocker, AdBlocker } from '../utils/adBlocker';
import { setupFingerPrintResistance } from '../utils/fingerPrintResistance';
import { setupSleepingTabs } from '../utils/sleepingTabs';
import { getSettings, setSettings } from '../utils/settings';
import { setupSettingsHandlers } from '../utils/settings';
import { TabManager } from '../utils/tabManager';
import { BookmarkManager } from '../utils/bookmarkManager';
import { DownloadManager } from '../utils/downloadManager';
import { ExtensionManager } from '../utils/extensionManager';
import { Theme } from '../utils/theme';
import { SeokjinAIIntegration } from './ai_integration/seokjin_ai';

// Initialize Seokjin AI
const seokjinAI = new SeokjinAIIntegration();

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

async function setupBrowserFeatures(window: BrowserWindow): Promise<void> {
  const settings = await getSettings();
  const adBlocker = new AdBlocker();
  setupAdBlocker(session.defaultSession, adBlocker);
  setupFingerPrintResistance(window);
  setupSleepingTabs(window);

  const theme = settings.dark_mode ? Theme.dark() : Theme.light();
  theme.applyToWindow(window);

  const tabManager = new TabManager(settings);
  const bookmarkManager = new BookmarkManager();
  const downloadManager = new DownloadManager();
  const extensionManager = new ExtensionManager();

  // Initialize managers
  await tabManager.initialize(window);
  await bookmarkManager.initialize();
  await downloadManager.initialize();
  await extensionManager.initialize();
}

app.whenReady().then(async () => {
  setupSettingsHandlers();
  const mainWindow = createWindow();
  setupContentSecurityPolicy(mainWindow);
  await setupBrowserFeatures(mainWindow);

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

ipcMain.handle('ai-process-input', async (event, input: string) => {
    return await seokjinAI.processInput(input);
});

ipcMain.handle('ai-learn-from-page', async (event, url: string) => {
    await seokjinAI.learnFromCurrentPage(url);
});

ipcMain.handle('ai-load-context-from-file', async (event, filePath: string) => {
    await seokjinAI.loadContextFromFile(filePath);
});

ipcMain.handle('ai-get-battery-level', async () => {
    return await seokjinAI.getBatteryLevel();
});

// Error handling
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  app.quit();
});
