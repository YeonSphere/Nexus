import 'package:flutter/material.dart';
import 'package:linux_webview/linux_webview.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const NexusApp());
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Browser',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BrowserWindow(),
    );
  }
}

class BrowserTab {
  final LinuxWebView webView;
  final String title;
  bool canGoBack;
  bool canGoForward;
  double progress;
  bool isSecure;

  BrowserTab({
    required String initialUrl,
    this.title = 'New Tab',
    this.canGoBack = false,
    this.canGoForward = false,
    this.progress = 0.0,
    this.isSecure = false,
  }) : webView = LinuxWebView(
          initialUrl: initialUrl,
          onProgress: (progress) => this.progress = progress,
          onSecurityStateChanged: (isSecure) => this.isSecure = isSecure,
          onNavigationStateChanged: (state) {
            canGoBack = state.canGoBack;
            canGoForward = state.canGoForward;
          },
        );
}

class BrowserWindow extends StatefulWidget {
  const BrowserWindow({super.key});

  @override
  State<BrowserWindow> createState() => _BrowserWindowState();
}

class _BrowserWindowState extends State<BrowserWindow> {
  final List<BrowserTab> _tabs = [];
  int _currentTabIndex = -1;

  @override
  void initState() {
    super.initState();
    _addNewTab();
  }

  void _addNewTab() {
    setState(() {
      _tabs.add(BrowserTab(initialUrl: 'https://www.google.com'));
      _currentTabIndex = _tabs.length - 1;
    });
  }

  void _closeTab(int index) {
    setState(() {
      _tabs.removeAt(index);
      if (_tabs.isEmpty) {
        _addNewTab();
      } else if (_currentTabIndex >= _tabs.length) {
        _currentTabIndex = _tabs.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = _tabs[_currentTabIndex];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: currentTab.canGoBack ? () => currentTab.webView.goBack() : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: currentTab.canGoForward ? () => currentTab.webView.goForward() : null,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => currentTab.webView.reload(),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    currentTab.isSecure ? Icons.lock : Icons.lock_open,
                    color: currentTab.isSecure ? Colors.green : Colors.red,
                  ),
                ),
                onSubmitted: (url) {
                  if (!url.startsWith('http://') && !url.startsWith('https://')) {
                    url = 'https://$url';
                  }
                  currentTab.webView.loadUrl(url);
                },
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: LinearProgressIndicator(
            value: currentTab.progress,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: _tabs.map((tab) => tab.webView).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTab,
        child: const Icon(Icons.add),
      ),
    );
  }
}
