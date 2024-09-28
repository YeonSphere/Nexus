import React, { useRef, useEffect, memo } from 'react';
import styled from 'styled-components';

const WebViewContainer = styled.div<{ $active: boolean }>`
  width: 100%;
  height: 100%;
  display: ${props => props.$active ? 'flex' : 'none'};
`;

interface WebViewProps {
  url: string;
  active: boolean;
  onTitleChange: (title: string) => void;
  onUrlChange: (url: string) => void;
  settings: {
    adBlockEnabled: boolean;
    fingerPrintResistanceEnabled: boolean;
  };
}

const WebView: React.FC<WebViewProps> = memo(({ url, active, onTitleChange, onUrlChange, settings }) => {
  const webviewRef = useRef<Electron.WebviewTag>(null);

  useEffect(() => {
    const webview = webviewRef.current;
    if (webview) {
      const handleDomReady = () => {
        webview.setZoomFactor(1);
        webview.setZoomLevel(0);
      };
      const handleTitleUpdate = (event: Electron.PageTitleUpdatedEvent) => onTitleChange(event.title);
      const handleNavigate = (event: Electron.DidNavigateEvent) => onUrlChange(event.url);

      webview.addEventListener('dom-ready', handleDomReady);
      webview.addEventListener('page-title-updated', handleTitleUpdate);
      webview.addEventListener('did-navigate', handleNavigate);

      // Apply settings
      if (settings.adBlockEnabled) {
        webview.send('enable-ad-block');
      }
      if (settings.fingerPrintResistanceEnabled) {
        webview.send('enable-fingerprint-resistance');
      }

      return () => {
        webview.removeEventListener('dom-ready', handleDomReady);
        webview.removeEventListener('page-title-updated', handleTitleUpdate);
        webview.removeEventListener('did-navigate', handleNavigate);
      };
    }
  }, [onTitleChange, onUrlChange, settings]);

  return (
    <WebViewContainer $active={active}>
      <webview
        ref={webviewRef}
        src={url}
        style={{ width: '100%', height: '100%' }}
        webpreferences="contextIsolation=yes, nodeIntegration=no"
      />
    </WebViewContainer>
  );
});

export default WebView;