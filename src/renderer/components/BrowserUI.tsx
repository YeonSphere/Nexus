import React from 'react';
import Navigation from './Navigation';
import TabManager from './TabManager';
import { TabContextProvider } from '../contexts/TabContext';

const BrowserUI: React.FC = () => {
  return (
    <TabContextProvider>
      <div id="browser-ui">
        <Navigation />
        <TabManager />
      </div>
    </TabContextProvider>
  );
};

export default BrowserUI;
