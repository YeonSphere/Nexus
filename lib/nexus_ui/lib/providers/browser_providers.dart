import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeTabProvider = StateProvider<String?>((ref) => null);

final tabsProvider = StateNotifierProvider<TabsNotifier, List<TabData>>((ref) {
  return TabsNotifier();
});

class TabData {
  final String id;
  final String url;
  final String title;
  final bool isLoading;

  TabData({
    required this.id,
    required this.url,
    this.title = 'New Tab',
    this.isLoading = false,
  });

  TabData copyWith({
    String? url,
    String? title,
    bool? isLoading,
  }) {
    return TabData(
      id: id,
      url: url ?? this.url,
      title: title ?? this.title,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TabsNotifier extends StateNotifier<List<TabData>> {
  TabsNotifier() : super([]);

  void addTab(String url) {
    final newTab = TabData(
      id: DateTime.now().toIso8601String(),
      url: url,
    );
    state = [...state, newTab];
  }

  void removeTab(String id) {
    state = state.where((tab) => tab.id != id).toList();
  }

  void updateTab(String id, {String? url, String? title, bool? isLoading}) {
    state = state.map((tab) {
      if (tab.id == id) {
        return tab.copyWith(
          url: url,
          title: title,
          isLoading: isLoading,
        );
      }
      return tab;
    }).toList();
  }
}
