import { BrowserWindow, Session } from 'electron';

export function setupFingerPrintResistance(window: BrowserWindow) {
  const session = window.webContents.session;
  setupHeaderResistance(session);
  setupJavaScriptResistance(window);
}

function setupHeaderResistance(session: Session) {
  session.webRequest.onBeforeSendHeaders((details, callback) => {
    const requestHeaders = { ...details.requestHeaders };
    
    // Modify or remove headers that could be used for fingerprinting
    requestHeaders['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';
    delete requestHeaders['Accept-Language'];
    
    callback({ requestHeaders });
  });

  session.webRequest.onHeadersReceived((details, callback) => {
    const responseHeaders = { ...details.responseHeaders };
    
    // Remove headers that could be used for fingerprinting
    const headersToRemove = ['User-Agent', 'X-Powered-By', 'Server', 'CF-RAY'];
    headersToRemove.forEach(header => {
      const lowerCaseHeader = header.toLowerCase();
      if (lowerCaseHeader in responseHeaders) {
        delete responseHeaders[lowerCaseHeader];
      }
    });
    
    // Add security headers
    responseHeaders['strict-transport-security'] = 'max-age=31536000; includeSubDomains';
    responseHeaders['x-frame-options'] = 'SAMEORIGIN';
    responseHeaders['x-content-type-options'] = 'nosniff';
    
    callback({ responseHeaders });
  });
}

function setupJavaScriptResistance(window: BrowserWindow) {
  // Override JavaScript methods commonly used for fingerprinting
  window.webContents.executeJavaScript(`
    (function() {
      const overrides = {
        'navigator.hardwareConcurrency': 4,
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

      // Override canvas fingerprinting
      const originalToDataURL = HTMLCanvasElement.prototype.toDataURL;
      HTMLCanvasElement.prototype.toDataURL = function(type) {
        if (type === 'image/png' && this.width === 16 && this.height === 16) {
          return 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAZdEVYdFNvZnR3YXJlAHBhaW50Lm5ldCA0LjAuMjHxIGmVAAAAEklEQVQ4T2NgGAWjYBSMAggAAAQQAAGFP6pyAAAAAElFTkSuQmCC';
        }
        return originalToDataURL.apply(this, arguments);
      };

      // Additional fingerprinting resistance
      Object.defineProperty(navigator, 'plugins', {
        get: () => [],
      });

      Object.defineProperty(navigator, 'mimeTypes', {
        get: () => [],
      });

      // Disable WebRTC IP leakage
      if (window.RTCPeerConnection) {
        window.RTCPeerConnection = class extends window.RTCPeerConnection {
          constructor(config) {
            if (config && config.iceServers) {
              config.iceServers = [];
            }
            super(config);
          }
        };
      }
    })();
  `);
}
