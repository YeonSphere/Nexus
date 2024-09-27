import React, { useState, useEffect } from 'react';

interface Settings {
  adBlockEnabled: boolean;
  // Add other settings properties here as needed
}

const Settings: React.FC = () => {
  const [settings, setSettings] = useState<Settings | null>(null);

  useEffect(() => {
    const loadSettings = async () => {
      try {
        const loadedSettings = await window.api.getSettings();
        setSettings(loadedSettings as unknown as Settings);
      } catch (error) {
        console.error('Failed to load settings:', error);
      }
    };
    loadSettings();
  }, []);

  const handleSettingToggle = async (settingName: keyof Settings) => {
    if (!settings) return;

    const newSettings = { ...settings, [settingName]: !settings[settingName] };
    setSettings(newSettings);

    try {
      await window.api.setSettings(newSettings);
    } catch (error) {
      console.error('Failed to save settings:', error);
      setSettings(settings); // Revert state if save fails
    }
  };

  if (settings === null) {
    return <div>Loading settings...</div>;
  }

  return (
    <div className="settings">
      <h2>Settings</h2>
      <label>
        <input
          type="checkbox"
          checked={settings.adBlockEnabled}
          onChange={() => handleSettingToggle('adBlockEnabled')}
        />
        Enable Ad Blocking
      </label>
      {/* Add more settings options here */}
    </div>
  );
};

export default Settings;
