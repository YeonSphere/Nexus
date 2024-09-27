import React from 'react';
import * as ReactDOM from 'react-dom';
import BrowserPage from './pages/BrowserPage';

// Main App component that wraps the BrowserPage in StrictMode
const App: React.FC = () => (
  <React.StrictMode>
    <BrowserPage />
  </React.StrictMode>
);

// Get the root element from the DOM
const rootElement = document.getElementById('root');
if (!rootElement) throw new Error('Failed to find the root element');

// Render the App component into the root
ReactDOM.render(<App />, rootElement);
