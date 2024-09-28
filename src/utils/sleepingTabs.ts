import { BrowserWindow, ipcMain } from 'electron';
import { getSettings, setSettings } from './settings';

const DEFAULT_SLEEP_THRESHOLD = 5 * 60 * 1000; // 5 minutes
const CHECK_INTERVAL = 1000; // 1 second

export async function setupSleepingTabs(window: BrowserWindow) {
  let inactiveTime = 0;
  let intervalId: NodeJS.Timeout | null = null;
  let sleepThreshold = DEFAULT_SLEEP_THRESHOLD;

  // Load sleep threshold from settings
  const settings = await getSettings();
  if (settings.sleepThreshold) {
    sleepThreshold = settings.sleepThreshold as number;
  }

  const checkInactivity = () => {
    if (window.isFocused()) {
      inactiveTime = 0;
    } else {
      inactiveTime += CHECK_INTERVAL;
      if (inactiveTime >= sleepThreshold) {
        window.webContents.send('tab-sleep');
        stopInactivityCheck();
      }
    }
  };

  const startInactivityCheck = () => {
    if (!intervalId) {
      intervalId = setInterval(checkInactivity, CHECK_INTERVAL);
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
  window.on('focus', stopInactivityCheck);
  window.on('blur', startInactivityCheck);
  window.on('closed', stopInactivityCheck);

  // Handle sleep threshold changes
  ipcMain.on('update-sleep-threshold', async (_, newThreshold: number) => {
    sleepThreshold = newThreshold;
    await setSettings({ ...await getSettings(), sleepThreshold: newThreshold });
  });
}
