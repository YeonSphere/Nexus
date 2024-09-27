import { ipcMain } from 'electron';
import * as fs from 'fs';
import * as path from 'path';

const settingsPath = path.join(__dirname, '../../settings.json');

export function getSettings(): Record<string, unknown> {
  try {
    return JSON.parse(fs.readFileSync(settingsPath, 'utf-8'));
  } catch (error) {
    return {};
  }
}

export function setSettings(settings: Record<string, unknown>): void {
  fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
}

export function setupSettingsHandlers() {
  ipcMain.handle('get-settings', () => getSettings());
  ipcMain.handle('set-settings', (_, settings: Record<string, unknown>) => setSettings(settings));
}
