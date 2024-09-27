import { BrowserWindow } from 'electron';

export function setupSleepingTabs(window: BrowserWindow) {
  let inactiveTime = 0;
  const SLEEP_THRESHOLD = 5 * 60 * 1000; // 5 minutes
  let intervalId: NodeJS.Timeout | null = null;

  const checkInactivity = () => {
    if (window.isFocused()) {
      inactiveTime = 0;
    } else {
      inactiveTime += 1000;
      if (inactiveTime >= SLEEP_THRESHOLD) {
        window.webContents.send('tab-sleep');
        stopInactivityCheck();
      }
    }
  };

  const startInactivityCheck = () => {
    if (!intervalId) {
      intervalId = setInterval(checkInactivity, 1000);
    }
  };

  const stopInactivityCheck = () => {
    if (intervalId) {
      clearInterval(intervalId);
      intervalId = null;
    }
  };

  const resetInactivity = () => {
    inactiveTime = 0;
    if (!window.isFocused()) {
      startInactivityCheck();
    }
  };

  window.webContents.on('did-start-navigation', resetInactivity);
  window.on('focus', () => {
    stopInactivityCheck();
    inactiveTime = 0;
  });
  window.on('blur', () => {
    inactiveTime = 0;
    startInactivityCheck();
  });

  window.on('closed', stopInactivityCheck);
}
