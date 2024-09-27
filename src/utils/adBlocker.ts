import * as fs from 'fs';
import * as path from 'path';
import { Session } from 'electron';

export class AdBlocker {
  private enabled: boolean = true;
  private filterList: string[] = [];

  constructor() {
    this.loadFilterList();
  }

  private loadFilterList(): void {
    try {
      const filePath = path.join(__dirname, '../../data/filter_lists.txt');
      const content = fs.readFileSync(filePath, 'utf-8');
      this.filterList = content.split('\n').filter(line => line.trim() !== '');
    } catch (error) {
      console.error('Failed to load filter lists:', error);
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
}

export function setupAdBlocker(session: Session, adBlocker: AdBlocker): void {
  session.webRequest.onBeforeRequest({ urls: ['<all_urls>'] }, (details, callback) => {
    const shouldBlock = adBlocker.shouldBlock(details.url);
    callback({ cancel: shouldBlock });
  });
}