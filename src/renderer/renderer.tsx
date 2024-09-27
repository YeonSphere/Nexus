import React from 'react';
import ReactDOM from 'react-dom';
import BrowserPage from './pages/BrowserPage';

const App: React.FC = () => (
  <React.StrictMode>
    <BrowserPage />
  </React.StrictMode>
);

ReactDOM.render(<App />, document.getElementById('root'));
