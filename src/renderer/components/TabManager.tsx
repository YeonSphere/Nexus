import React, { useState, useEffect } from 'react';
import { WebView, WebViewProps } from './WebView';

interface Tab {
  id: number;
  url: string;
  title: string;
  webView: React.RefObject<Electron.WebviewTag>;
}

const TabManager: React.FC = () => {
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

  const setActiveTabById = (id: number) => {
    if (tabs.some(tab => tab.id === id)) {
      setActiveTab(id);
    }
  };

  const getActiveTab = () => tabs.find(tab => tab.id === activeTab);

  const updateTabTitle = (id: number, title: string) => {
    setTabs(tabs.map(tab => tab.id === id ? { ...tab, title } : tab));
  };

  const updateTabUrl = (id: number, url: string) => {
    setTabs(tabs.map(tab => tab.id === id ? { ...tab, url } : tab));
  };

  return (
    <div id="tab-bar">
      {tabs.map(tab => (
        <div
          key={tab.id}
          className={`tab ${activeTab === tab.id ? 'active' : ''}`}
          onClick={() => setActiveTabById(tab.id)}
        >
          {tab.title}
          <button onClick={() => closeTab(tab.id)}>×</button>
        </div>
      ))}
      <button onClick={() => createTab('about:blank')}>+</button>
      <div id="content-area">
        {tabs.map(tab => (
          <WebView
            key={tab.id}
            ref={tab.webView}
            url={tab.url}
            active={activeTab === tab.id}
            onTitleChange={(title) => updateTabTitle(tab.id, title)}
            onUrlChange={(url) => updateTabUrl(tab.id, url)}
          />
        ))}
      </div>
    </div>
  );
};

export default TabManager;
