import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class LinuxWebView extends StatefulWidget {
  final String initialUrl;
  final ValueChanged<double>? onProgress;
  final ValueChanged<bool>? onSecurityStateChanged;
  final ValueChanged<NavigationState>? onNavigationStateChanged;
  final GlobalKey<_LinuxWebViewState> _key;

  LinuxWebView({
    super.key,
    required this.initialUrl,
    this.onProgress,
    this.onSecurityStateChanged,
    this.onNavigationStateChanged,
  }) : _key = GlobalKey<_LinuxWebViewState>();

  Future<void> loadUrl(String url) async {
    await _key.currentState?.loadUrl(url);
  }

  Future<void> goBack() async {
    await _key.currentState?.goBack();
  }

  Future<void> goForward() async {
    await _key.currentState?.goForward();
  }

  Future<void> reload() async {
    await _key.currentState?.reload();
  }

  @override
  State<LinuxWebView> createState() => _LinuxWebViewState();
}

class NavigationState {
  final bool canGoBack;
  final bool canGoForward;

  NavigationState({
    required this.canGoBack,
    required this.canGoForward,
  });

  factory NavigationState.fromMap(Map<dynamic, dynamic> map) {
    return NavigationState(
      canGoBack: map['canGoBack'] as bool,
      canGoForward: map['canGoForward'] as bool,
    );
  }
}

class _LinuxWebViewState extends State<LinuxWebView> {
  static const MethodChannel _channel = MethodChannel('linux_webview');
  int? _viewId;

  @override
  void initState() {
    super.initState();
    _createWebView();
    _setupMethodCallHandler();
  }

  Future<void> _createWebView() async {
    try {
      final Map<String, dynamic> args = {
        'initialUrl': widget.initialUrl,
      };
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('createWebView', args);
      setState(() {
        _viewId = result['viewId'] as int;
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to create WebView: ${e.message}');
    }
  }

  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onProgressChanged':
          if (widget.onProgress != null) {
            final double progress = call.arguments['progress'] as double;
            widget.onProgress!(progress);
          }
          break;
        case 'onSecurityChanged':
          if (widget.onSecurityStateChanged != null) {
            final bool isSecure = call.arguments['isSecure'] as bool;
            widget.onSecurityStateChanged!(isSecure);
          }
          break;
        case 'onNavigationStateChanged':
          if (widget.onNavigationStateChanged != null) {
            final state = NavigationState.fromMap(
                call.arguments as Map<dynamic, dynamic>);
            widget.onNavigationStateChanged!(state);
          }
          break;
      }
    });
  }

  Future<void> loadUrl(String url) async {
    if (_viewId == null) return;
    try {
      await _channel.invokeMethod('loadUrl', {
        'viewId': _viewId,
        'url': url,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to load URL: ${e.message}');
    }
  }

  Future<void> goBack() async {
    if (_viewId == null) return;
    try {
      await _channel.invokeMethod('goBack', {
        'viewId': _viewId,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to go back: ${e.message}');
    }
  }

  Future<void> goForward() async {
    if (_viewId == null) return;
    try {
      await _channel.invokeMethod('goForward', {
        'viewId': _viewId,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to go forward: ${e.message}');
    }
  }

  Future<void> reload() async {
    if (_viewId == null) return;
    try {
      await _channel.invokeMethod('reload', {
        'viewId': _viewId,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to reload: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement native view embedding
    return Container();
  }

  @override
  void dispose() {
    if (_viewId != null) {
      _channel.invokeMethod('dispose', {'viewId': _viewId});
    }
    super.dispose();
  }
}
