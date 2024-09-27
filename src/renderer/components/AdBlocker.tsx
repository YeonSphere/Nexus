import React, { useState, useEffect } from 'react';

interface AdBlockerProps {
  enabled: boolean;
  onToggle: (enabled: boolean) => void;
}

const AdBlocker: React.FC<AdBlockerProps> = ({ enabled, onToggle }) => {
  const [blockedCount, setBlockedCount] = useState<number>(0);

  useEffect(() => {
    // This effect would typically connect to the ad-blocking system
    // to update the blocked count. For now, it's just a placeholder.
    const updateBlockedCount = () => {
      // In a real implementation, this would get the actual count
      // from the ad-blocking system.
      setBlockedCount(prev => prev + 1);
    };

    if (enabled) {
      const interval = setInterval(updateBlockedCount, 5000);
      return () => clearInterval(interval);
    }
  }, [enabled]);

  return (
    <div className="ad-blocker">
      <label>
        <input
          type="checkbox"
          checked={enabled}
          onChange={(e) => onToggle(e.target.checked)}
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
