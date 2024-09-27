import React, { forwardRef, useEffect, useCallback } from 'react';
import { WebviewTag } from 'electron';

export interface WebViewProps {
  url: string;
  active: boolean;
  onTitleChange: (title: string) => void;
  onUrlChange: (url: string) => void;
}

export const WebView = forwardRef<WebviewTag, WebViewProps>(
  ({ url, active, onTitleChange, onUrlChange }, ref) => {
    const handleTitleChange = useCallback((e: Electron.PageTitleUpdatedEvent) => {
      onTitleChange(e.title);
    }, [onTitleChange]);

    const handleUrlChange = useCallback((e: Electron.DidNavigateEvent) => {
      onUrlChange(e.url);
    }, [onUrlChange]);

    useEffect(() => {
      const webview = (ref as React.RefObject<WebviewTag>)?.current;
      if (webview) {
        webview.addEventListener('page-title-updated', handleTitleChange);
        webview.addEventListener('did-navigate', handleUrlChange);

        return () => {
          webview.removeEventListener('page-title-updated', handleTitleChange);
          webview.removeEventListener('did-navigate', handleUrlChange);
        };
      }
    }, [handleTitleChange, handleUrlChange, ref]);

    return (
      <webview
        ref={ref}
        src={url}
        style={{ display: active ? 'flex' : 'none', width: '100%', height: '100%' }}
      />
    );
  }
);
