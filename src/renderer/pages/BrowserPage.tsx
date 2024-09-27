import React from 'react';
import { TabContextProvider } from '../contexts/TabContext';
import TabManager from '../components/TabManager';

const BrowserPage: React.FC = () => {
  return (
    <TabContextProvider>
      <div className="browser-page">
        <TabManager />
      </div>
    </TabContextProvider>
  );
};

export default BrowserPage;
