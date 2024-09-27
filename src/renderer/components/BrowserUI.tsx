import React, { useState } from 'react';
import styled, { createGlobalStyle } from 'styled-components';
import Navigation from './Navigation';
import TabManager from './TabManager';
import { TabContextProvider } from '../contexts/TabContext';

const GlobalStyle = createGlobalStyle`
  body {
    margin: 0;
    padding: 0;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #1e1e2e;
    color: #cdd6f4;
  }
`;

const BrowserContainer = styled.div`
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: #1e1e2e;
`;

const Header = styled.header`
  display: flex;
  align-items: center;
  padding: 10px;
  background-color: #181825;
  border-bottom: 2px solid #313244;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
`;

const Content = styled.main`
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
`;

const BrowserUI: React.FC = () => {
  const [settings] = useState({
    adBlockEnabled: true,
    fingerPrintResistanceEnabled: true,
    sleepingTabsEnabled: true,
  });

  return (
    <>
      <GlobalStyle />
      <TabContextProvider>
        <BrowserContainer>
          <Header>
            <Navigation />
          </Header>
          <Content>
            <TabManager settings={settings} />
          </Content>
        </BrowserContainer>
      </TabContextProvider>
    </>
  );
};

export default BrowserUI;
