import * as fs from 'fs';
import * as path from 'path';
import { Session } from 'electron';
import fetch from 'node-fetch';

const FILTER_LISTS = [
  'https://easylist.to/easylist/easylist.txt',
  'https://easylist.to/easylist/easyprivacy.txt',
];

export class AdBlocker {
  private enabled: boolean = true;
  private filterList: string[] = [];

  constructor() {
    const dataDir = path.join(__dirname, '../../data');
    if (!fs.existsSync(dataDir)) {
      fs.mkdirSync(dataDir, { recursive: true });
    }
    this.loadFilterList();
  }

  private async loadFilterList(): Promise<void> {
    try {
      const filePath = path.join(__dirname, '../../data/filter_lists.txt');
      if (fs.existsSync(filePath)) {
        const content = fs.readFileSync(filePath, 'utf-8');
        this.filterList = content.split('\n').filter(line => line.trim() !== '');
      } else {
        console.warn('Local filter list file not found. Downloading from remote sources.');
        await this.downloadAndSaveFilterLists();
      }
    } catch (error) {
      console.error('Failed to load filter lists:', error);
    }
  }

  private async downloadAndSaveFilterLists(): Promise<void> {
    try {
      const responses = await Promise.all(FILTER_LISTS.map(url => fetch(url)));
      const texts = await Promise.all(responses.map(response => response.text()));
      const combinedFilters = texts.join('\n');

      const filePath = path.join(__dirname, '../../data/filter_lists.txt');
      fs.writeFileSync(filePath, combinedFilters);

      this.filterList = combinedFilters.split('\n').filter(line => line.trim() !== '' && !line.startsWith('!'));
    } catch (error) {
      console.error('Failed to download and save filter lists:', error);
      this.filterList = []; // Set an empty filter list if download fails
    }
  }

  isEnabled(): boolean {
    return this.enabled;
  }

  setEnabled(value: boolean): void {
    this.enabled = value;
  }

  shouldBlock(url: string): boolean {
    if (!this.enabled) return false;
    return this.filterList.some(filter => url.toLowerCase().includes(filter.toLowerCase()));
  }

  addFilter(filter: string): void {
    if (!this.filterList.includes(filter)) {
      this.filterList.push(filter);
      this.saveFilterList();
    }
  }

  removeFilter(filter: string): void {
    const index = this.filterList.indexOf(filter);
    if (index !== -1) {
      this.filterList.splice(index, 1);
      this.saveFilterList();
    }
  }

  private saveFilterList(): void {
    try {
      const filePath = path.join(__dirname, '../../data/filter_lists.txt');
      fs.writeFileSync(filePath, this.filterList.join('\n'));
    } catch (error) {
      console.error('Failed to save filter lists:', error);
    }
  }

  public async updateFilterLists(): Promise<void> {
    await this.downloadAndSaveFilterLists();
    await this.loadFilterList();
  }
}

export function setupAdBlocker(session: Session, adBlocker: AdBlocker): void {
  session.webRequest.onBeforeRequest({ urls: ['<all_urls>'] }, (details, callback) => {
    const shouldBlock = adBlocker.shouldBlock(details.url);
    callback({ cancel: shouldBlock });
  });
}