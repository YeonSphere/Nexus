import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SidePanelType { bookmarks, history, downloads }

class SidePanel extends StatefulWidget {
  final SidePanelType type;
  final VoidCallback onClose;

  const SidePanel({
    Key? key,
    required this.type,
    required this.onClose,
  }) : super(key: key);

  @override
  _SidePanelState createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppTheme.primaryPurple.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String title;
    IconData icon;

    switch (widget.type) {
      case SidePanelType.bookmarks:
        title = 'Bookmarks';
        icon = Icons.bookmark;
        break;
      case SidePanelType.history:
        title = 'History';
        icon = Icons.history;
        break;
      case SidePanelType.downloads:
        title = 'Downloads';
        icon = Icons.download;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryPurple.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.type) {
      case SidePanelType.bookmarks:
        return _buildBookmarksContent();
      case SidePanelType.history:
        return _buildHistoryContent();
      case SidePanelType.downloads:
        return _buildDownloadsContent();
    }
  }

  Widget _buildBookmarksContent() {
    // TODO: Implement bookmarks content
    return const Center(child: Text('Bookmarks coming soon'));
  }

  Widget _buildHistoryContent() {
    // TODO: Implement history content
    return const Center(child: Text('History coming soon'));
  }

  Widget _buildDownloadsContent() {
    // TODO: Implement downloads content
    return const Center(child: Text('Downloads coming soon'));
  }
}
