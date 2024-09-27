import React from 'react';
import ReactDOM from 'react-dom';
import BrowserUI from './components/BrowserUI';

console.log('Renderer process started');

try {
  ReactDOM.render(
    <React.StrictMode>
      <BrowserUI />
    </React.StrictMode>,
    document.getElementById('root')
  );
  console.log('ReactDOM.render called successfully');
} catch (error) {
  console.error('Error rendering BrowserUI:', error);
}
