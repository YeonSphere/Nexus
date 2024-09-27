import * as fs from 'fs';
import * as path from 'path';

export class AdBlocker {
  private enabled: boolean = true;
  private filterList: string[] = [];

  constructor() {
    this.loadFilterList();
  }

  private loadFilterList() {
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
    return this.filterList.some(filter => url.includes(filter));
  }

  addFilter(filter: string): void {
    this.filterList.push(filter);
    this.saveFilterList();
  }

  removeFilter(filter: string): void {
    this.filterList = this.filterList.filter(f => f !== filter);
    this.saveFilterList();
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