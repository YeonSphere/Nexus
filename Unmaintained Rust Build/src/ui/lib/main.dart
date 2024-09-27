import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'bridge_generated.dart';

void main() {
  runApp(NexusBrowserApp());
}

class NexusBrowserApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Browser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: BrowserHomePage(),
    );
  }
}

class BrowserHomePage extends StatefulWidget {
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
      ..loadRequest(Uri.parse(_urlController.text))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nexus Browser'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              final settings = await api.getSettings();
              // TODO: Implement settings dialog
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => _webViewController.goBack(),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () => _webViewController.goForward(),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () => _webViewController.reload(),
              ),
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: 'Enter URL',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (url) => _loadUrl(url),
                ),
              ),
              IconButton(
                icon: Icon(Icons.search),
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
              icon: Icon(Icons.home),
              onPressed: () => _loadUrl('https://yeonsphere.github.io/'),
            ),
            IconButton(
              icon: Icon(Icons.bookmark),
              onPressed: () {
                // TODO: Implement bookmarks
              },
            ),
            IconButton(
              icon: Icon(Icons.history),
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
