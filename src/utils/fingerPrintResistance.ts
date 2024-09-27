import { BrowserWindow, Session } from 'electron';

export function setupFingerPrintResistance(window: BrowserWindow) {
  const session = window.webContents.session;
  setupHeaderResistance(session);
  setupJavaScriptResistance(window);
}

function setupHeaderResistance(session: Session) {
  session.webRequest.onHeadersReceived((details, callback) => {
    const responseHeaders = { ...details.responseHeaders };
    
    // Remove headers that could be used for fingerprinting
    delete responseHeaders['user-agent'];
    delete responseHeaders['x-powered-by'];
    delete responseHeaders['server'];
    
    callback({ responseHeaders });
  });
}

function setupJavaScriptResistance(window: BrowserWindow) {
  // Override JavaScript methods commonly used for fingerprinting
  window.webContents.executeJavaScript(`
    (function() {
      const overrides = {
        'navigator.hardwareConcurrency': 2,
        'navigator.deviceMemory': 8,
        'screen.width': 1920,
        'screen.height': 1080,
        'navigator.platform': 'Win32',
        'navigator.userAgent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      };

      for (const [path, value] of Object.entries(overrides)) {
        const parts = path.split('.');
        const obj = parts.slice(0, -1).reduce((o, p) => o[p], window);
        const prop = parts[parts.length - 1];
        Object.defineProperty(obj, prop, { get: () => value });
      }
    })();
  `);
}
