import { BrowserView, BrowserWindow } from 'electron';

class TabManager {
  private tabs: BrowserView[];
  private activeTabIndex: number;
  private window: BrowserWindow;

  constructor(window: BrowserWindow) {
    this.tabs = [];
    this.activeTabIndex = -1;
    this.window = window;
  }

  createTab(url: string): void {
    const newTab = new BrowserView({
      webPreferences: {
        nodeIntegration: false,
        contextIsolation: true,
        sandbox: true,
      }
    });

    newTab.webContents.loadURL(url);
    this.tabs.push(newTab);
    this.setActiveTab(this.tabs.length - 1);
  }

  closeTab(index: number): void {
    if (index < 0 || index >= this.tabs.length) return;

    const closedTab = this.tabs.splice(index, 1)[0];
    closedTab.destroy();

    if (this.tabs.length === 0) {
      this.activeTabIndex = -1;
    } else if (index <= this.activeTabIndex) {
      this.setActiveTab(Math.max(0, this.activeTabIndex - 1));
    }
  }

  setActiveTab(index: number): void {
    if (index < 0 || index >= this.tabs.length) return;

    if (this.activeTabIndex !== -1) {
      this.window.removeBrowserView(this.tabs[this.activeTabIndex]);
    }

    this.activeTabIndex = index;
    this.window.addBrowserView(this.tabs[index]);
    this.updateActiveTabBounds();
  }

  private updateActiveTabBounds(): void {
    const bounds = this.window.getBounds();
    this.tabs[this.activeTabIndex].setBounds({
      x: 0,
      y: 80, // Adjust this value based on your navigation bar height
      width: bounds.width,
      height: bounds.height - 80,
    });
  }

  getActiveTab(): BrowserView | null {
    return this.activeTabIndex !== -1 ? this.tabs[this.activeTabIndex] : null;
  }

  getTabs(): BrowserView[] {
    return this.tabs;
  }

  getActiveTabIndex(): number {
    return this.activeTabIndex;
  }
}

export default TabManager;
