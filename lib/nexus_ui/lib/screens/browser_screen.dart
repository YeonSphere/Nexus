import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/browser_top_bar.dart';
import '../widgets/tab_strip.dart';

class BrowserScreen extends ConsumerWidget {
  const BrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          const TabStrip(),
          const BrowserTopBar(),
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
