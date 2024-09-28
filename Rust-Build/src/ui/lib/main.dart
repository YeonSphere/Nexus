import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'bridge_generated.dart';
import 'package:seokjin_ai/seokjin_ai.dart';

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
  final SeokjinAI seokjinAI = SeokjinAI();

  @override
  void initState() {
    super.initState();
    _urlController.text = 'https://yeonsphere.github.io/';
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _urlController.text = url;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _urlController.text = url;
            });
          },
        ),
      )
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
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Settings'),
                      content: Text('Settings: $settings'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ask Seokjin AI...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (input) async {
                      final response = await _processAIInput(input);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Seokjin: $response')),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.school),
                  onPressed: _aiLearnFromCurrentPage,
                  tooltip: 'Learn from this page',
                ),
              ],
            ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bookmarks feature coming soon!')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                // TODO: Implement history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History feature coming soon!')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.android),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Seokjin AI'),
                      content: const Text('Seokjin AI is ready to assist you!'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              tooltip: 'Seokjin AI',
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _processAIInput(String input) async {
    try {
      return await seokjinAI.processInput(input);
    } catch (e) {
      print('Error processing AI input: $e');
      return 'Sorry, I encountered an error while processing your request.';
    }
  }

  Future<void> _aiLearnFromCurrentPage() async {
    try {
      final String currentUrl = await _webViewController.currentUrl() ?? '';
      await seokjinAI.learnFromWeb(currentUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seokjin AI has learned from the current page.')),
      );
    } catch (e) {
      print('Error learning from current page: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Seokjin AI couldn\'t learn from the current page.')),
      );
    }
  }

  void _loadUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    _webViewController.loadRequest(Uri.parse(url));
  }
}
