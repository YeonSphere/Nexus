import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Color(0xFF1a1a2e),
    ),
  );
  runApp(const NexusApp());
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Browser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C39FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C39FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final List<TabInfo> _tabs = [];
  int _currentTabIndex = 0;
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _addNewTab();
  }

  void _addNewTab() {
    setState(() {
      _tabs.add(TabInfo(
        key: UniqueKey(),
        url: 'https://www.google.com',
        title: 'New Tab',
        isActive: true,
      ));
      _currentTabIndex = _tabs.length - 1;
      _tabController = TabController(
        length: _tabs.length,
        vsync: this,
        initialIndex: _currentTabIndex,
      );
    });
  }

  void _closeTab(int index) {
    setState(() {
      _tabs.removeAt(index);
      if (_tabs.isEmpty) {
        _addNewTab();
      } else {
        _currentTabIndex = _currentTabIndex > 0 ? _currentTabIndex - 1 : 0;
      }
      _tabController = TabController(
        length: _tabs.length,
        vsync: this,
        initialIndex: _currentTabIndex,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          flexibleSpace: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 40, left: 8, right: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        if (_tabs[_currentTabIndex].controller != null) {
                          _tabs[_currentTabIndex].controller!.goBack();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        if (_tabs[_currentTabIndex].controller != null) {
                          _tabs[_currentTabIndex].controller!.goForward();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        if (_tabs[_currentTabIndex].controller != null) {
                          _tabs[_currentTabIndex].controller!.reload();
                        }
                      },
                    ),
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                          decoration: InputDecoration(
                            hintText: 'Search or enter URL',
                            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            suffixIcon: Icon(Icons.search, color: colorScheme.primary),
                          ),
                          onSubmitted: (url) {
                            if (_tabs[_currentTabIndex].controller != null) {
                              final formattedUrl = url.startsWith('http') ? url : 'https://$url';
                              _tabs[_currentTabIndex].controller!.loadUrl(formattedUrl);
                            }
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark),
                      onPressed: () {
                        // Show bookmarks
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _tabs.map((tab) => Tab(text: tab.title)).toList(),
                onTap: (index) {
                  setState(() {
                    _currentTabIndex = index;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTab,
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          return WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse(tab.url)),
          );
        }).toList(),
      ),
      endDrawer: Drawer(
        child: Container(
          color: colorScheme.surface,
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primaryContainer],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nexus Browser',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fast, Secure, Private',
                      style: TextStyle(
                        color: colorScheme.onPrimary.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New Tab'),
                onTap: () {
                  _addNewTab();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('History'),
                onTap: () {
                  // Show history
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: const Text('Bookmarks'),
                onTap: () {
                  // Show bookmarks
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Downloads'),
                onTap: () {
                  // Show downloads
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  // Show settings
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabInfo {
  final Key key;
  final String url;
  String title;
  bool isActive;
  WebViewController? controller;

  TabInfo({
    required this.key,
    required this.url,
    required this.title,
    required this.isActive,
    this.controller,
  });
}