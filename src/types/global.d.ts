interface Window {
  api: {
    getSettings: () => Promise<{
      adBlockEnabled: boolean;
      fingerPrintResistanceEnabled: boolean;
      darkModeEnabled: boolean;
      customUserAgent: string;
    }>;
    setSettings: (settings: {
      adBlockEnabled: boolean;
      fingerPrintResistanceEnabled: boolean;
      darkModeEnabled: boolean;
      customUserAgent: string;
    }) => Promise<void>;
    navigateToUrl: (url: string) => Promise<void>;
    goBack: () => Promise<void>;
    goForward: () => Promise<void>;
    reload: () => Promise<void>;
    clearBrowsingData: () => Promise<void>;
    getCurrentUrl: () => Promise<string>;
    aiProcessInput: (input: string) => Promise<string>;
    aiLearnFromPage: (url: string) => Promise<void>;
  }
}
