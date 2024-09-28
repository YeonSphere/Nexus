import React, { useContext } from 'react';
import BrowserUI from '../components/BrowserUI';
import { TabContextProvider } from '../contexts/TabContext';
import Settings from '../components/Settings';

const BrowserPage: React.FC = () => {
  return (
    <TabContextProvider>
      <BrowserUI />
      <Settings />
    </TabContextProvider>
  );
};

export default BrowserPage;
