import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TabManager {
  static const int maxTabs = 20;
  static const Duration inactiveTabTimeout = Duration(minutes: 30);
  
  final List<TabData> _tabs = [];
  final Map<String, DateTime> _lastAccessed = {};
  
  void addTab(TabData tab) {
    if (_tabs.length >= maxTabs) {
      _removeOldestInactiveTab();
    }
    _tabs.add(tab);
    _updateLastAccessed(tab.id);
  }
  
  void removeTab(String tabId) {
    _tabs.removeWhere((tab) => tab.id == tabId);
    _lastAccessed.remove(tabId);
  }
  
  void activateTab(String tabId) {
    _updateLastAccessed(tabId);
  }
  
  void _updateLastAccessed(String tabId) {
    _lastAccessed[tabId] = DateTime.now();
  }
  
  void _removeOldestInactiveTab() {
    if (_tabs.isEmpty) return;
    
    final now = DateTime.now();
    String? oldestTabId;
    DateTime? oldestAccess;
    
    _lastAccessed.forEach((tabId, lastAccess) {
      if (oldestAccess == null || lastAccess.isBefore(oldestAccess)) {
        oldestTabId = tabId;
        oldestAccess = lastAccess;
      }
    });
    
    if (oldestTabId != null && 
        oldestAccess != null && 
        now.difference(oldestAccess) > inactiveTabTimeout) {
      removeTab(oldestTabId!);
    }
  }
  
  void suspendInactiveTabs() {
    final now = DateTime.now();
    _lastAccessed.forEach((tabId, lastAccess) {
      if (now.difference(lastAccess) > inactiveTabTimeout) {
        final tab = _tabs.firstWhere((tab) => tab.id == tabId);
        tab.suspend();
      }
    });
  }
  
  List<TabData> get tabs => List.unmodifiable(_tabs);
}

class TabData {
  final String id;
  final String url;
  String title;
  bool isActive;
  bool isSuspended;
  WebViewController? controller;
  
  TabData({
    required this.id,
    required this.url,
    this.title = 'New Tab',
    this.isActive = false,
    this.isSuspended = false,
    this.controller,
  });
  
  void suspend() {
    if (!isSuspended && controller != null) {
      controller!.loadUrl('about:blank');
      isSuspended = true;
    }
  }
  
  void resume() {
    if (isSuspended && controller != null) {
      controller!.loadUrl(url);
      isSuspended = false;
    }
  }
}
