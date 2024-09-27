import React, { useContext } from 'react';
import styled from 'styled-components';
import { TabContext } from '../contexts/TabContext';
import { WebView } from './WebView';

const TabContainer = styled.div`
  display: flex;
  background-color: #34495e;
  padding: 5px 5px 0;
`;

const Tab = styled.div<{ active: boolean }>`
  padding: 8px 20px;
  background-color: ${props => props.active ? '#f0f0f0' : '#2c3e50'};
  color: ${props => props.active ? '#2c3e50' : '#ecf0f1'};
  border-radius: 5px 5px 0 0;
  margin-right: 5px;
  cursor: pointer;
  display: flex;
  align-items: center;
`;

const CloseButton = styled.span`
  margin-left: 10px;
  font-size: 0.8em;
  &:hover {
    color: #e74c3c;
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

  const { tabs, activeTab, setActiveTab, addTab, removeTab } = context;

  return (
    <>
      <TabContainer>
        {tabs.map((tab: TabData) => (
          <Tab key={tab.id} active={activeTab === tab.id} onClick={() => setActiveTab(tab.id)}>
            {tab.title || 'New Tab'}
            <CloseButton onClick={(e) => { e.stopPropagation(); removeTab(tab.id); }}>✕</CloseButton>
          </Tab>
        ))}
        <Tab active={false} onClick={() => addTab('about:blank')}>+</Tab>
      </TabContainer>
      <ContentArea>
        {tabs.map((tab: TabData) => (
          <WebView
            key={tab.id}
            url={tab.url}
            active={activeTab === tab.id}
            onTitleChange={(title: string) => {/* Implement title change logic */}}
            onUrlChange={(url: string) => {/* Implement URL change logic */}}
          />
        ))}
      </ContentArea>
    </>
  );
};

export default TabManager;
