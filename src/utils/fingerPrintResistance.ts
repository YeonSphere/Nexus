import { BrowserWindow, Session } from 'electron';

export function setupFingerPrintResistance(window: BrowserWindow) {
  const session = window.webContents.session;
  setupHeaderResistance(session);
  setupJavaScriptResistance(window);
  setupAdditionalResistance(window);
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
    responseHeaders['strict-transport-security'] = ['max-age=31536000; includeSubDomains'];
    responseHeaders['x-frame-options'] = ['SAMEORIGIN'];
    responseHeaders['x-content-type-options'] = ['nosniff'];
    responseHeaders['referrer-policy'] = ['strict-origin-when-cross-origin'];
    responseHeaders['permissions-policy'] = ['geolocation=(), microphone=(), camera=()'];
    
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

      // Override performance.now() to reduce timing precision
      const originalPerformanceNow = performance.now;
      performance.now = function() {
        return Math.floor(originalPerformanceNow.call(performance) / 100) * 100;
      };

      // Override Battery Status API
      if (navigator.getBattery) {
        navigator.getBattery = () => Promise.resolve({
          charging: true,
          chargingTime: 0,
          dischargingTime: Infinity,
          level: 1,
          onchargingchange: null,
          onchargingtimechange: null,
          ondischargingtimechange: null,
          onlevelchange: null
        });
      }
    })();
  `);
}

function setupAdditionalResistance(window: BrowserWindow) {
  window.webContents.executeJavaScript(`
    // Randomize canvas fingerprint
    const originalGetContext = HTMLCanvasElement.prototype.getContext;
    HTMLCanvasElement.prototype.getContext = function(contextType) {
      const context = originalGetContext.apply(this, arguments);
      if (contextType === '2d') {
        const originalFillRect = context.fillRect;
        context.fillRect = function() {
          arguments[0] += Math.random() * 0.01;
          arguments[1] += Math.random() * 0.01;
          return originalFillRect.apply(this, arguments);
        };
      }
      return context;
    };

    // Spoof audio fingerprint
    const originalGetChannelData = AudioBuffer.prototype.getChannelData;
    AudioBuffer.prototype.getChannelData = function(channel) {
      const array = originalGetChannelData.call(this, channel);
      for (let i = 0; i < array.length; i += 100) {
        array[i] += Math.random() * 0.0001;
      }
      return array;
    };

    // Override Geolocation API
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition = function(success, error, options) {
        error({ code: 1, message: "User denied Geolocation" });
      };
      navigator.geolocation.watchPosition = function(success, error, options) {
        error({ code: 1, message: "User denied Geolocation" });
        return 0;
      };
    }

    // Spoof client rectangles and element sizes
    const originalGetBoundingClientRect = Element.prototype.getBoundingClientRect;
    Element.prototype.getBoundingClientRect = function() {
      const rect = originalGetBoundingClientRect.call(this);
      return {
        ...rect,
        x: rect.x + (Math.random() - 0.5) * 0.01,
        y: rect.y + (Math.random() - 0.5) * 0.01,
        width: rect.width + (Math.random() - 0.5) * 0.01,
        height: rect.height + (Math.random() - 0.5) * 0.01
      };
    };
  `);
}
