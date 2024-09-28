import React, { useState, useEffect } from 'react';
import styled from 'styled-components';

interface Settings {
  adBlockEnabled: boolean;
  defaultSearchEngine: string;
  homePage: string;
}

const SettingsContainer = styled.div`
  padding: 20px;
  background-color: #f5f5f5;
  border-radius: 8px;
`;

const SettingItem = styled.div`
  margin-bottom: 15px;
`;

const SettingLabel = styled.label`
  display: flex;
  align-items: center;
  cursor: pointer;
`;

const SettingInput = styled.input`
  margin-right: 10px;
`;

const SettingSelect = styled.select`
  margin-top: 5px;
  padding: 5px;
  width: 100%;
`;

const Settings: React.FC = () => {
  const [settings, setSettings] = useState<Settings>({
    adBlockEnabled: false,
    defaultSearchEngine: '',
    homePage: '',
  });

  useEffect(() => {
    const loadSettings = async () => {
      try {
        const loadedSettings = await window.api.getSettings();
        setSettings(loadedSettings as Settings);
      } catch (error) {
        console.error('Failed to load settings:', error);
      }
    };
    loadSettings();
  }, []);

  const handleSettingChange = async (settingName: keyof Settings, value: boolean | string) => {
    if (!settings) return;

    const previousSettings = { ...settings };
    const newSettings = { ...previousSettings, [settingName]: value };

    setSettings(newSettings);

    try {
      await window.api.setSettings(newSettings);
    } catch (error) {
      console.error('Failed to save settings:', error);
      setSettings(previousSettings); // Revert to previous valid state
    }
  };

  if (settings === null) {
    return <div>Loading settings...</div>;
  }

  return (
    <SettingsContainer>
      <h2>Settings</h2>
      <SettingItem>
        <SettingLabel>
          <SettingInput
            type="checkbox"
            checked={settings.adBlockEnabled}
            onChange={(e) => handleSettingChange('adBlockEnabled', e.target.checked)}
          />
          Enable Ad Blocking
        </SettingLabel>
      </SettingItem>
      <SettingItem>
        <SettingLabel>Default Search Engine</SettingLabel>
        <SettingSelect
          value={settings.defaultSearchEngine}
          onChange={(e) => handleSettingChange('defaultSearchEngine', e.target.value)}
        >
          <option value="https://search.brave.com/search?q=">Brave</option>
          <option value="https://searx.be/search?q=">Searx</option>
          <option value="https://www.google.com/search?q=">Google</option>
          <option value="https://www.bing.com/search?q=">Bing</option>
          <option value="https://search.naver.com/search.naver?query=">Naver</option>
        </SettingSelect>
      </SettingItem>
      <SettingItem>
        <SettingLabel>Homepage</SettingLabel>
        <SettingInput
          type="text"
          value={settings.homePage}
          onChange={(e) => handleSettingChange('homePage', e.target.value)}
        />
      </SettingItem>
    </SettingsContainer>
  );
};

export default Settings;
