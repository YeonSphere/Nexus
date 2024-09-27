import React, { forwardRef, useEffect } from 'react';
import { WebviewTag } from 'electron';

export interface WebViewProps {
  url: string;
  active: boolean;
  onTitleChange: (title: string) => void;
  onUrlChange: (url: string) => void;
}

export const WebView = forwardRef<Electron.WebviewTag, WebViewProps>(
  ({ url, active, onTitleChange, onUrlChange }, ref) => {
    useEffect(() => {
      const webview = (ref as React.RefObject<Electron.WebviewTag>).current;
      if (webview) {
        webview.addEventListener('page-title-updated', (e: any) => {
          onTitleChange(e.title);
        });
        webview.addEventListener('did-navigate', (e: any) => {
          onUrlChange(e.url);
        });
      }
    }, [onTitleChange, onUrlChange]);

    return (
      <webview
        ref={ref}
        src={url}
        style={{ display: active ? 'flex' : 'none', width: '100%', height: '100%' }}
      />
    );
  }
);
