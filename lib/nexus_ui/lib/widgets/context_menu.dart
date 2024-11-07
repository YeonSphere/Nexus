import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserContextMenu extends StatelessWidget {
  final Offset position;
  final String? selectedText;
  final String? linkUrl;
  final String? imageUrl;
  final WebViewController controller;
  final VoidCallback onDismiss;

  const BrowserContextMenu({
    Key? key,
    required this.position,
    this.selectedText,
    this.linkUrl,
    this.imageUrl,
    required this.controller,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 250),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedText != null) ...[
                    _ContextMenuItem(
                      icon: Icons.copy,
                      text: 'Copy',
                      onTap: () {
                        // Copy to clipboard
                        onDismiss();
                      },
                    ),
                    _ContextMenuItem(
                      icon: Icons.search,
                      text: 'Search',
                      onTap: () {
                        // Search selected text
                        onDismiss();
                      },
                    ),
                  ],
                  if (linkUrl != null) ...[
                    _ContextMenuItem(
                      icon: Icons.open_in_new,
                      text: 'Open in new tab',
                      onTap: () {
                        // Open in new tab
                        onDismiss();
                      },
                    ),
                    _ContextMenuItem(
                      icon: Icons.copy_link,
                      text: 'Copy link',
                      onTap: () {
                        // Copy link
                        onDismiss();
                      },
                    ),
                  ],
                  if (imageUrl != null) ...[
                    _ContextMenuItem(
                      icon: Icons.image,
                      text: 'Save image',
                      onTap: () {
                        // Save image
                        onDismiss();
                      },
                    ),
                    _ContextMenuItem(
                      icon: Icons.open_in_new,
                      text: 'Open image in new tab',
                      onTap: () {
                        // Open image
                        onDismiss();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContextMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ContextMenuItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(text),
          ],
        ),
      ),
    );
  }
}
