import React, { useState, useEffect, useContext } from 'react';
import Navigation from './Navigation';
import TabManager from './TabManager';
import { TabContextProvider } from '../contexts/TabContext';
import styled from 'styled-components';
import AdBlocker from './AdBlocker';
import { TabContext } from '../contexts/TabContext';

const BrowserContainer = styled.div`
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: #f0f0f0;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
`;

const Header = styled.header`
  display: flex;
  align-items: center;
  padding: 10px;
  background-color: #2c3e50;
  color: white;
`;

const Logo = styled.div`
  font-size: 1.5em;
  font-weight: bold;
  margin-right: 20px;
`;

const Content = styled.main`
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
`;

interface Settings {
  adBlockEnabled: boolean;
  fingerPrintResistanceEnabled: boolean;
  sleepingTabsEnabled: boolean;
}

const BrowserUI: React.FC = () => {
  const [settings, setSettings] = useState<Settings>({
    adBlockEnabled: true,
    fingerPrintResistanceEnabled: true,
    sleepingTabsEnabled: true,
  });

  useEffect(() => {
    window.api.getSettings().then((newSettings: Record<string, unknown>) => {
      setSettings(newSettings as unknown as Settings);
    });
  }, []);

  const handleAdBlockToggle = (enabled: boolean) => {
    setSettings(prevSettings => ({ ...prevSettings, adBlockEnabled: enabled }));
    window.api.setSettings({ ...settings, adBlockEnabled: enabled });
  };

  const context = useContext(TabContext);
  if (!context) return null; // or some loading indicator
  const { tabs } = context;

  return (
    <TabContextProvider>
      <BrowserContainer>
        <Header>
          <Logo>Nexus</Logo>
          <Navigation />
          <AdBlocker enabled={settings.adBlockEnabled} onToggle={handleAdBlockToggle} />
        </Header>
        <Content>
          {tabs.length > 0 && <TabManager settings={settings} />}
        </Content>
      </BrowserContainer>
    </TabContextProvider>
  );
};

export default BrowserUI;
