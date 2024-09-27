import React, { createContext, useState, useEffect } from 'react';

interface Tab {
  id: number;
  url: string;
  title: string;
  webView: React.RefObject<Electron.WebviewTag>;
}

interface TabContextType {
  tabs: Tab[];
  activeTab: number | null;
  createTab: (url: string) => void;
  closeTab: (id: number) => void;
  setActiveTab: (id: number) => void;
  updateTabTitle: (id: number, title: string) => void;
  updateTabUrl: (id: number, url: string) => void;
}

export const TabContext = createContext<TabContextType>({} as TabContextType);

export const TabContextProvider: React.FC = ({ children }) => {
  const [tabs, setTabs] = useState<Tab[]>([]);
  const [activeTab, setActiveTab] = useState<number | null>(null);
  const [nextId, setNextId] = useState(0);

  useEffect(() => {
    createTab('https://yeonsphere.github.io/');
  }, []);

  const createTab = (url: string) => {
    const newTab: Tab = {
      id: nextId,
      url,
      title: 'New Tab',
      webView: React.createRef<Electron.WebviewTag>(),
    };
    setTabs([...tabs, newTab]);
    setActiveTab(newTab.id);
    setNextId(nextId + 1);
  };

  const closeTab = (id: number) => {
    setTabs(tabs.filter(tab => tab.id !== id));
    if (activeTab === id) {
      setActiveTab(tabs[tabs.length - 2]?.id || null);
    }
  };

  const updateTabTitle = (id: number, title: string) => {
    setTabs(tabs.map(tab => tab.id === id ? { ...tab, title } : tab));
  };

  const updateTabUrl = (id: number, url: string) => {
    setTabs(tabs.map(tab => tab.id === id ? { ...tab, url } : tab));
  };

  return (
    <TabContext.Provider value={{
      tabs,
      activeTab,
      createTab,
      closeTab,
      setActiveTab,
      updateTabTitle,
      updateTabUrl,
    }}>
      {children}
    </TabContext.Provider>
  );
};
