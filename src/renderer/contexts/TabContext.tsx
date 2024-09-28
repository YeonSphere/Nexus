import React, { createContext, useState, useEffect, useRef, useCallback } from 'react';

interface Tab {
  id: number;
  url: string;
  title: string;
  webView: React.RefObject<Electron.WebviewTag>;
}

interface TabContextType {
  tabs: Tab[];
  activeTab: number | null;
  createTab: (url: string) => Promise<void>;
  closeTab: (id: number) => void;
  setActiveTab: (id: number | null) => void;
  updateTabTitle: (id: number, title: string) => void;
  updateTabUrl: (id: number, url: string) => void;
}

export const TabContext = createContext<TabContextType | undefined>(undefined);

export const TabContextProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [tabs, setTabs] = useState<Tab[]>([]);
  const [activeTab, setActiveTab] = useState<number | null>(null);
  const nextTabId = useRef(1);

  useEffect(() => {
    createTab('https://yeonsphere.github.io/nexus/');
  }, []);

  const createTab = useCallback(async (url: string) => {
    const newTab: Tab = {
      id: nextTabId.current++,
      url,
      title: 'New Tab',
      webView: React.createRef<Electron.WebviewTag>(),
    };
    setTabs(prevTabs => [...prevTabs, newTab]);
    setActiveTab(newTab.id);
  }, []);

  const closeTab = useCallback((id: number) => {
    setTabs(prevTabs => {
      const updatedTabs = prevTabs.filter(tab => tab.id !== id);
      if (updatedTabs.length === 0) {
        createTab('about:blank');
      } else if (activeTab === id) {
        setActiveTab(updatedTabs[updatedTabs.length - 1].id);
      }
      return updatedTabs;
    });
  }, [activeTab, createTab]);

  const updateTabTitle = useCallback((id: number, title: string) => {
    setTabs(prevTabs => prevTabs.map(tab => tab.id === id ? { ...tab, title } : tab));
  }, []);

  const updateTabUrl = useCallback((id: number, url: string) => {
    setTabs(prevTabs => prevTabs.map(tab => tab.id === id ? { ...tab, url } : tab));
  }, []);

  const contextValue: TabContextType = {
    tabs,
    activeTab,
    createTab,
    closeTab,
    setActiveTab,
    updateTabTitle,
    updateTabUrl,
  };

  return (
    <TabContext.Provider value={contextValue}>
      {children}
    </TabContext.Provider>
  );
};
