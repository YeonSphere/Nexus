import React, { useState, useEffect } from 'react';

interface AdBlockerProps {
  enabled: boolean;
  onToggle: (enabled: boolean) => void;
}

const AdBlocker: React.FC<AdBlockerProps> = ({ enabled, onToggle }) => {
  const [blockedCount, setBlockedCount] = useState(0);

  useEffect(() => {
    let intervalId: NodeJS.Timeout;

    const updateBlockedCount = async () => {
      try {
        const count = await window.api.getAdBlockedCount();
        setBlockedCount(count);
      } catch (error) {
        console.error('Failed to get ad blocked count:', error);
      }
    };

    if (enabled) {
      updateBlockedCount(); // Initial update
      intervalId = setInterval(updateBlockedCount, 5000);
    }

    return () => {
      if (intervalId) clearInterval(intervalId);
    };
  }, [enabled]);

  const handleToggle = async (isEnabled: boolean) => {
    try {
      await window.api.setSettings({ ...settings, adBlockEnabled: !isEnabled });
      onToggle(isEnabled);
    } catch (error) {
      console.error('Failed to toggle ad blocker:', error);
    }
  };

  return (
    <div className="ad-blocker">
      <label>
        <input
          type="checkbox"
          checked={enabled}
          onChange={(e) => handleToggle(e.target.checked)}
        />
        Enable Ad Blocker
      </label>
      {enabled && (
        <p>Ads blocked: {blockedCount}</p>
      )}
    </div>
  );
};

export default AdBlocker;
