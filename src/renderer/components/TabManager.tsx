import React, { useContext } from 'react';
import styled from 'styled-components';
import { TabContext } from '../contexts/TabContext';
import WebView from './WebView';

const TabContainer = styled.div`
  display: flex;
  background-color: #3a80d2;
  padding: 5px 5px 0;
  overflow-x: auto;
  &::-webkit-scrollbar {
    height: 5px;
  }
  &::-webkit-scrollbar-thumb {
    background-color: rgba(255, 255, 255, 0.3);
    border-radius: 5px;
  }
`;

const Tab = styled.div<{ active: boolean }>`
  padding: 8px 20px;
  background-color: ${props => props.active ? '#4a90e2' : '#3a80d2'};
  color: white;
  border-radius: 8px 8px 0 0;
  margin-right: 5px;
  cursor: pointer;
  display: flex;
  align-items: center;
  transition: background-color 0.3s ease;
  &:hover {
    background-color: ${props => props.active ? '#4a90e2' : '#4085d6'};
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

  return (
    <>
      <TabContainer>
        {tabs.map((tab: TabData) => (
          <Tab key={tab.id} active={activeTab === tab.id} onClick={() => setActiveTab(tab.id)}>
            {tab.title || 'New Tab'}
            <CloseButton onClick={(e) => { e.stopPropagation(); closeTab(tab.id); }}>✕</CloseButton>
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
            onTitleChange={(title: string) => {
              console.log('Title changed:', title);
              updateTabTitle(tab.id, title);
            }}
            onUrlChange={(url: string) => {
              console.log('URL changed:', url);
              updateTabUrl(tab.id, url);
            }}
          />
        ))}
      </ContentArea>
    </>
  );
};

export default TabManager;
