import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

class UrlBar extends StatefulWidget {
  const UrlBar({
    Key? key,
    required this.webViewController,
    this.onUrlChanged,
    this.onBookmarkPressed,
  }) : super(key: key);

  final Future<WebViewController> webViewController;
  final Function(String)? onUrlChanged;
  final VoidCallback? onBookmarkPressed;

  @override
  State<UrlBar> createState() => _UrlBarState();
}

class _UrlBarState extends State<UrlBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isSecure = false;
  bool _isLoading = false;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUrl() async {
    final controller = await widget.webViewController;
    final url = await controller.currentUrl();
    setState(() {
      _currentUrl = url ?? '';
      _controller.text = _formatUrl(_currentUrl);
      _isSecure = _currentUrl.startsWith('https://');
    });
    widget.onUrlChanged?.call(_currentUrl);
  }

  String _formatUrl(String url) {
    if (url.startsWith('https://')) {
      return url.replaceFirst('https://', '');
    } else if (url.startsWith('http://')) {
      return url.replaceFirst('http://', '');
    }
    return url;
  }

  Future<void> _handleUrlSubmitted(String input) async {
    setState(() => _isLoading = true);
    
    try {
      final controller = await widget.webViewController;
      String url = input;
      
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        if (Uri.tryParse(url)?.hasScheme ?? false) {
          url = 'https://$url';
        } else {
          url = 'https://www.google.com/search?q=${Uri.encodeComponent(url)}';
        }
      }
      
      await controller.loadUrl(url);
      _loadUrl();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFF2d2d44),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(
            _isSecure ? Icons.lock_outline : Icons.info_outline,
            size: 16,
            color: _isSecure ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search or enter URL',
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: _handleUrlSubmitted,
              textInputAction: TextInputAction.go,
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFa700e3)),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              iconSize: 20,
              color: Color(0xFFa700e3),
              splashRadius: 20,
              onPressed: widget.onBookmarkPressed,
            ),
        ],
      ),
    );
  }
}
