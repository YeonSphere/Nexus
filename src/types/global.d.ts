interface Window {
  api: {
    getSettings: () => Promise<Record<string, unknown>>;
    setSettings: (settings: Record<string, unknown>) => Promise<void>;
    navigateToUrl: (url: string) => Promise<void>;
  }
}
