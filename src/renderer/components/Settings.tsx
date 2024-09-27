import React, { useState, useEffect } from 'react';

const Settings: React.FC = () => {
  const [adBlockEnabled, setAdBlockEnabled] = useState(true);

  useEffect(() => {
    // Load settings when component mounts
    window.api.getSettings().then((settings) => {
      setAdBlockEnabled(settings.adBlockEnabled);
    });
  }, []);

  const handleAdBlockToggle = () => {
    const newValue = !adBlockEnabled;
    setAdBlockEnabled(newValue);
    window.api.setSettings({ adBlockEnabled: newValue });
  };

  return (
    <div className="settings">
      <h2>Settings</h2>
      <label>
        <input
          type="checkbox"
          checked={adBlockEnabled}
          onChange={handleAdBlockToggle}
        />
        Enable Ad Blocking
      </label>
    </div>
  );
};

export default Settings;
