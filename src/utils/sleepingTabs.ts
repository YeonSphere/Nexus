import { BrowserWindow } from 'electron';

export function setupSleepingTabs(window: BrowserWindow) {
  let inactiveTime = 0;
  const SLEEP_THRESHOLD = 5 * 60 * 1000; // 5 minutes
  let intervalId: NodeJS.Timeout;

  const checkInactivity = () => {
    if (window.isFocused()) {
      inactiveTime = 0;
    } else {
      inactiveTime += 1000;
      if (inactiveTime >= SLEEP_THRESHOLD) {
        window.webContents.send('tab-sleep');
        clearInterval(intervalId); // Stop checking after sending sleep signal
      }
    }
  };

  intervalId = setInterval(checkInactivity, 1000);

  window.webContents.on('did-start-navigation', () => {
    inactiveTime = 0;
    if (!intervalId) {
      intervalId = setInterval(checkInactivity, 1000);
    }
  });

  window.on('focus', () => {
    inactiveTime = 0;
    if (!intervalId) {
      intervalId = setInterval(checkInactivity, 1000);
    }
  });

  window.on('closed', () => {
    if (intervalId) {
      clearInterval(intervalId);
    }
  });
}
