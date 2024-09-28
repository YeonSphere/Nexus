import React, { useState, useEffect } from 'react';
import styled, { createGlobalStyle, ThemeProvider } from 'styled-components';
import Navigation from './Navigation';
import TabManager from './TabManager';
import { TabContextProvider } from '../contexts/TabContext';
import AdBlocker from './AdBlocker';
import { lightTheme, darkTheme } from '../themes';

const GlobalStyle = createGlobalStyle`
  body {
    margin: 0;
    padding: 0;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: ${props => props.theme.backgroundColor};
    color: ${props => props.theme.textColor};
  }
`;

const BrowserContainer = styled.div`
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: ${props => props.theme.backgroundColor};
`;

const Header = styled.header`
  display: flex;
  align-items: center;
  padding: 10px;
  background-color: ${props => props.theme.headerColor};
  border-bottom: 2px solid ${props => props.theme.borderColor};
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
`;

const Content = styled.main`
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
`;

const BrowserUI: React.FC = () => {
  const [settings, setSettings] = useState({
    adBlockEnabled: true,
    fingerPrintResistanceEnabled: true,
    sleepingTabsEnabled: true,
    darkMode: false,
  });

  useEffect(() => {
    const loadSettings = async () => {
      try {
        const savedSettings = await window.api.getSettings();
        setSettings(prevSettings => ({ ...prevSettings, ...savedSettings }));
      } catch (error) {
        console.error('Failed to load settings:', error);
      }
    };

    loadSettings();
  }, []);

  const toggleAdBlocker = async (enabled: boolean) => {
    try {
      await window.api.setSettings({ ...settings, adBlockEnabled: enabled });
      setSettings(prevSettings => ({ ...prevSettings, adBlockEnabled: enabled }));
    } catch (error) {
      console.error('Failed to toggle ad blocker:', error);
    }
  };

  const toggleTheme = async () => {
    try {
      const newDarkMode = !settings.darkModeEnabled;
      await window.api.setSettings({ ...settings, darkModeEnabled: newDarkMode });
      setSettings(prevSettings => ({ ...prevSettings, darkModeEnabled: newDarkMode }));
    } catch (error) {
      console.error('Failed to toggle theme:', error);
    }
  };

  return (
    <ThemeProvider theme={settings.darkMode ? darkTheme : lightTheme}>
      <GlobalStyle />
      <TabContextProvider>
        <BrowserContainer>
          <Header>
            <Navigation />
            <AdBlocker enabled={settings.adBlockEnabled} onToggle={toggleAdBlocker} />
            <button onClick={toggleTheme}>Toggle Theme</button>
          </Header>
          <Content>
            <TabManager settings={settings} />
          </Content>
        </BrowserContainer>
      </TabContextProvider>
    </ThemeProvider>
  );
};

export default BrowserUI;
