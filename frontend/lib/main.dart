import 'package:flutter/material.dart';
import 'package:linux_webview/linux_webview.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const NexusApp());
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Browser',
      theme: ThemeData.dark(useMaterial3: true),
      home: const BrowserWindow(),
    );
  }
}

class BrowserWindow extends StatefulWidget {
  const BrowserWindow({super.key});

  @override
  State<BrowserWindow> createState() => _BrowserWindowState();
}

class _BrowserWindowState extends State<BrowserWindow> {
  final List<TabInfo> _tabs = [];
  int _activeTabIndex = -1;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addNewTab();
  }

  void _addNewTab([String url = 'https://www.google.com']) {
    final webView = LinuxWebView(
      initialUrl: url,
      onProgress: (progress) {
        setState(() {
          if (_activeTabIndex >= 0) {
            _tabs[_activeTabIndex].progress = progress;
          }
        });
      },
      onSecurityStateChanged: (isSecure) {
        setState(() {
          if (_activeTabIndex >= 0) {
            _tabs[_activeTabIndex].isSecure = isSecure;
          }
        });
      },
      onNavigationStateChanged: (state) {
        setState(() {
          if (_activeTabIndex >= 0) {
            _tabs[_activeTabIndex].canGoBack = state.canGoBack;
            _tabs[_activeTabIndex].canGoForward = state.canGoForward;
            // Since we don't have onUrlChanged callback, update URL from navigation state if possible
            _urlController.text = url;
          }
        });
      },
    );

    setState(() {
      _tabs.add(TabInfo(
        webView: webView,
        url: url,
        title: 'New Tab',  // Since we don't have onTitleChanged, use a static title
        progress: 0.0,
        isSecure: false,
        canGoBack: false,
        canGoForward: false,
      ));
      _activeTabIndex = _tabs.length - 1;
    });
  }

  void _closeTab(int index) {
    if (_tabs.length <= 1) return;

    setState(() {
      _tabs.removeAt(index);
      if (_activeTabIndex >= _tabs.length) {
        _activeTabIndex = _tabs.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTitleBar(),
          _buildTabBar(),
          _buildNavigationBar(),
          Expanded(
            child: _activeTabIndex >= 0 ? _buildWebView() : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      height: 30,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          const SizedBox(width: 80),
          Expanded(
            child: GestureDetector(
              onDoubleTap: () {
                windowManager.maximize();
              },
              child: Center(
                child: Text(
                  _activeTabIndex >= 0 ? _tabs[_activeTabIndex].title : 'Nexus',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          ),
          const WindowButtons(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 35,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                return _buildTab(tab, index);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewTab,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(TabInfo tab, int index) {
    final isActive = index == _activeTabIndex;
    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        margin: const EdgeInsets.only(left: 1),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.background,
          border: Border(
            bottom: BorderSide(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            if (tab.isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.public, size: 16),
            const SizedBox(width: 8),
            Text(
              tab.title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 8),
            if (_tabs.length > 1)
              InkWell(
                onTap: () => _closeTab(index),
                child: const Icon(Icons.close, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    if (_activeTabIndex < 0) return const SizedBox();
    final tab = _tabs[_activeTabIndex];

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: tab.canGoBack ? () => tab.webView.goBack() : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: tab.canGoForward ? () => tab.webView.goForward() : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => tab.webView.reload(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Icon(
                    tab.isSecure ? Icons.lock : Icons.lock_open,
                    size: 16,
                    color: tab.isSecure ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter URL',
                      ),
                      onSubmitted: (url) {
                        if (_activeTabIndex >= 0) {
                          if (!url.startsWith('http://') && !url.startsWith('https://')) {
                            url = 'https://$url';
                          }
                          tab.webView.loadUrl(url);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addNewTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    final tab = _tabs[_activeTabIndex];
    return Stack(
      children: [
        tab.webView,
        if (tab.isLoading)
          LinearProgressIndicator(
            value: tab.progress,
            backgroundColor: Colors.transparent,
          ),
      ],
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        WindowButton(
          icon: Icons.remove,
          onPressed: () => windowManager.minimize(),
        ),
        WindowButton(
          icon: Icons.crop_square,
          onPressed: () => windowManager.maximize(),
        ),
        WindowButton(
          icon: Icons.close,
          onPressed: () => windowManager.close(),
        ),
      ],
    );
  }
}

class WindowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const WindowButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 30,
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
      ),
    );
  }
}

class TabInfo {
  final LinuxWebView webView;
  String url;
  String title;
  bool isLoading;
  double progress;
  bool isSecure;
  bool canGoBack;
  bool canGoForward;

  TabInfo({
    required this.webView,
    required this.url,
    this.title = 'New Tab',
    this.isLoading = true,
    this.progress = 0.0,
    this.isSecure = false,
    this.canGoBack = false,
    this.canGoForward = false,
  });
}
