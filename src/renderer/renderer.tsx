import React from 'react';
import { createRoot } from 'react-dom/client';
import BrowserPage from './pages/BrowserPage';
import './styles/main.css';

console.log('Renderer process started');

try {
  const container = document.getElementById('root');
  if (!container) throw new Error('Root element not found');
  
  const root = createRoot(container);
  root.render(
    <React.StrictMode>
      <BrowserPage />
    </React.StrictMode>
  );
  console.log('React root created and rendered successfully');
} catch (error) {
  console.error('Error rendering BrowserPage:', error);
}
