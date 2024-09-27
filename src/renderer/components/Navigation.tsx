import React, { useState, useContext } from 'react';
import { TabContext } from '../contexts/TabContext'; // Assuming we create a TabContext

const Navigation: React.FC = () => {
  const [url, setUrl] = useState('https://yeonsphere.github.io/nexus/');
  const { activeTab, updateTabUrl } = useContext(TabContext);

  const handleNavigate = () => {
    if (activeTab !== null) {
      updateTabUrl(activeTab, url);
    }
  };

  return (
    <div className="navigation">
      <button onClick={() => window.history.back()}>&#8592;</button>
      <button onClick={() => window.history.forward()}>&#8594;</button>
      <button onClick={() => window.location.reload()}>&#8635;</button>
      <input 
        type="text" 
        value={url} 
        onChange={(e) => setUrl(e.target.value)}
        onKeyPress={(e) => e.key === 'Enter' && handleNavigate()}
      />
      <button onClick={handleNavigate}>Go</button>
      <button>&#9881;</button>
      <button>&#128295;</button>
    </div>
  );
};

export default Navigation;
