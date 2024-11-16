import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../services/ad_blocker.dart';

class WebViewTab extends StatefulWidget {
  final String initialUrl;
  final Function(String) onUrlChanged;

  const WebViewTab({
    Key? key,
    required this.initialUrl,
    required this.onUrlChanged,
  }) : super(key: key);

  @override
  State<WebViewTab> createState() => _WebViewTabState();
}

class _WebViewTabState extends State<WebViewTab> {
  late InAppWebViewController _webViewController;
  final AdBlocker _adBlocker = AdBlocker();
  double progress = 0;

  @override
  void initState() {
    super.initState();
    _initializeAdBlocker();
  }

  Future<void> _initializeAdBlocker() async {
    await _adBlocker.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(widget.initialUrl)),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              useShouldOverrideUrlLoading: true,
              useOnLoadResource: true,
              javaScriptEnabled: true,
              cacheEnabled: true,
              userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            ),
          ),
          onWebViewCreated: (InAppWebViewController controller) {
            _webViewController = controller;
            _setupWebView(controller);
          },
          onLoadStart: (controller, url) {
            if (url != null) {
              widget.onUrlChanged(url.toString());
            }
          },
          onProgressChanged: (controller, progress) {
            setState(() {
              this.progress = progress / 100;
            });
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            return _adBlocker.contentBlockerHandler
                .shouldOverrideUrlLoading(navigationAction);
          },
          onLoadResource: (controller, resource) async {
            // Additional resource blocking logic can be added here
          },
        ),
        if (progress < 1.0)
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
      ],
    );
  }

  void _setupWebView(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: 'adBlocker',
      callback: (args) {
        // Handle any JavaScript callbacks from the ad blocker
        return null;
      },
    );

    // Inject the ad blocking script
    controller.evaluateJavascript(source: _adBlocker.injectedScript);
  }
}
