import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus_browser/screens/browser_screen.dart';
import 'package:nexus_browser/services/browser_service.dart';
import 'package:nexus_browser/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: NexusBrowser(),
    ),
  );
}

class NexusBrowser extends ConsumerWidget {
  const NexusBrowser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Nexus Browser',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const BrowserScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
