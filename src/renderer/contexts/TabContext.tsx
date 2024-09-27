import React, { createContext, useState, useEffect, useRef } from 'react';

interface Tab {
  id: number;
  url: string;
  title: string;
  webView: React.RefObject<Electron.WebviewTag>;
}

interface TabContextType {
  tabs: Tab[];
  activeTab: number;
  createTab: (url: string) => void;
  closeTab: (id: number) => void;
  setActiveTab: React.Dispatch<React.SetStateAction<number>>;
  updateTabTitle: (id: number, title: string) => void;
  updateTabUrl: (id: number, url: string) => void;
  addTab: (url: string) => void;
  removeTab: (id: number) => void;
}

export const TabContext = createContext<TabContextType | undefined>(undefined);

export const TabContextProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [tabs, setTabs] = useState<Tab[]>([]);
  const [activeTab, setActiveTab] = useState<number>(0);
  const nextTabId = useRef(1);

  useEffect(() => {
    createTab('https://yeonsphere.github.io/nexus/');
  }, []);

  const createTab = (url: string) => {
    const newTab: Tab = {
      id: nextTabId.current++,
      url,
      title: 'New Tab',
      webView: React.createRef<Electron.WebviewTag>(),
    };
    setTabs([...tabs, newTab]);
    setActiveTab(newTab.id);
  };

  const closeTab = (id: number) => {
    setTabs(tabs.filter(tab => tab.id !== id));
    if (activeTab === id) {
      setActiveTab(tabs[tabs.length - 2]?.id || 0);
    }
  };

  const updateTabTitle = (id: number, title: string) => {
    setTabs(tabs.map(tab => tab.id === id ? { ...tab, title } : tab));
  };

  const updateTabUrl = (id: number, url: string) => {
    setTabs(tabs.map(tab => tab.id === id ? { ...tab, url } : tab));
  };

  const addTab = createTab;
  const removeTab = closeTab;

  const contextValue: TabContextType = {
    tabs,
    activeTab,
    createTab,
    closeTab,
    setActiveTab,
    updateTabTitle,
    updateTabUrl,
    addTab,
    removeTab,
  };

  return (
    <TabContext.Provider value={contextValue}>
      {children}
    </TabContext.Provider>
  );
};
