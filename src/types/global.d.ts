interface Window {
  api: {
    getSettings: () => Promise<any>;
    setSettings: (settings: any) => Promise<void>;
    navigateToUrl: (url: string) => Promise<void>;
  }
}
