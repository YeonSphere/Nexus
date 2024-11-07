import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

class TabStrip extends ConsumerWidget {
  const TabStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryPurple.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 1, // Will be dynamic based on tabs
              itemBuilder: (context, index) {
                return Container(
                  width: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      const Icon(Icons.public, size: 16),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'New Tab',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
