import React, { useContext, useEffect } from 'react';
import styled from 'styled-components';
import { TabContext } from '../contexts/TabContext';
import WebView from './WebView';

const TabContainer = styled.div`
  display: flex;
  background-color: ${props => props.theme.tabBarBackgroundColor};
  padding: 5px 5px 0;
  overflow-x: auto;
  &::-webkit-scrollbar {
    height: 5px;
  }
  &::-webkit-scrollbar-thumb {
    background-color: ${props => props.theme.scrollbarThumbColor};
    border-radius: 5px;
  }
`;

const Tab = styled.div<{ active: boolean }>`
  padding: 8px 20px;
  background-color: ${props => props.active ? props.theme.activeTabBackgroundColor : props.theme.inactiveTabBackgroundColor};
  color: ${props => props.theme.tabTextColor};
  border-radius: 8px 8px 0 0;
  margin-right: 5px;
  cursor: pointer;
  display: flex;
  align-items: center;
  transition: background-color 0.3s ease;
  &:hover {
    background-color: ${props => props.active ? props.theme.activeTabBackgroundColor : props.theme.tabHoverBackgroundColor};
  }
`;

const CloseButton = styled.span`
  margin-left: 10px;
  font-size: 0.8em;
  opacity: 0.7;
  transition: opacity 0.3s ease;
  &:hover {
    opacity: 1;
  }
`;

const ContentArea = styled.div`
  flex: 1;
  position: relative;
`;

interface TabData {
  id: number;
  title: string;
  url: string;
}

const TabManager: React.FC<{ settings: any }> = ({ settings }) => {
  const context = useContext(TabContext);

  if (!context) {
    return <div>Loading...</div>; // Or some other fallback UI
  }

  const { tabs, activeTab, setActiveTab, createTab, closeTab, updateTabTitle, updateTabUrl } = context;

  useEffect(() => {
    // Create an initial tab if there are no tabs
    if (tabs.length === 0) {
      createTab('about:blank');
    }
  }, []);

  const handleCloseTab = (tabId: number) => {
    if (tabs.length > 1) {
      closeTab(tabId);
    } else {
      // If it's the last tab, create a new one before closing
      createTab('about:blank').then(() => closeTab(tabId));
    }
  };

  return (
    <>
      <TabContainer>
        {tabs.map((tab: TabData) => (
          <Tab key={tab.id} active={activeTab === tab.id} onClick={() => setActiveTab(tab.id)}>
            {tab.title || 'New Tab'}
            <CloseButton onClick={(e) => { e.stopPropagation(); handleCloseTab(tab.id); }}>✕</CloseButton>
          </Tab>
        ))}
        <Tab active={false} onClick={() => createTab('about:blank')}>+</Tab>
      </TabContainer>
      <ContentArea>
        {tabs.map((tab: TabData) => (
          <WebView
            key={tab.id}
            url={tab.url}
            active={activeTab === tab.id}
            onTitleChange={(title: string) => updateTabTitle(tab.id, title)}
            onUrlChange={(url: string) => updateTabUrl(tab.id, url)}
            settings={settings}
          />
        ))}
      </ContentArea>
    </>
  );
};

export default TabManager;
