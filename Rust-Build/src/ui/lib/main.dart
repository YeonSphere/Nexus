import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'bridge_generated.dart';

void main() {
  runApp(const NexusBrowserApp());
}

class NexusBrowserApp extends StatelessWidget {
  const NexusBrowserApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Browser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const BrowserHomePage(),
    );
  }
}

class BrowserHomePage extends StatefulWidget {
  const BrowserHomePage({Key? key}) : super(key: key);

  @override
  _BrowserHomePageState createState() => _BrowserHomePageState();
}

class _BrowserHomePageState extends State<BrowserHomePage> {
  final TextEditingController _urlController = TextEditingController();
  late WebViewController _webViewController;
  final api = NexusApi();

  @override
  void initState() {
    super.initState();
    _urlController.text = 'https://yeonsphere.github.io/';
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(_urlController.text));
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexus Browser'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final settings = await api.getSettings();
              // TODO: Implement settings dialog
              if (mounted) {
                // Use settings to update UI or show dialog
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _webViewController.goBack(),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _webViewController.goForward(),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _webViewController.reload(),
              ),
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    hintText: 'Enter URL',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: _loadUrl,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _loadUrl(_urlController.text),
              ),
            ],
          ),
          Expanded(
            child: WebViewWidget(controller: _webViewController),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => _loadUrl('https://yeonsphere.github.io/'),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark),
              onPressed: () {
                // TODO: Implement bookmarks
              },
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                // TODO: Implement history
              },
            ),
          ],
        ),
      ),
    );
  }

  void _loadUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    _webViewController.loadRequest(Uri.parse(url));
  }
}
