import { ipcMain } from 'electron';
import * as fs from 'fs-extra';
import * as path from 'path';

const settingsPath = path.join(__dirname, '../../settings.json');

export async function getSettings(): Promise<Record<string, unknown>> {
  try {
    const data = await fs.readJson(settingsPath);
    return data;
  } catch (error) {
    console.error('Error reading settings:', error);
    return {};
  }
}

export async function setSettings(settings: Record<string, unknown>): Promise<void> {
  try {
    await fs.writeJson(settingsPath, settings, { spaces: 2 });
  } catch (error) {
    console.error('Error writing settings:', error);
  }
}

export function setupSettingsHandlers() {
  ipcMain.handle('get-settings', async () => await getSettings());
  ipcMain.handle('set-settings', async (_, settings: Record<string, unknown>) => await setSettings(settings));
}
