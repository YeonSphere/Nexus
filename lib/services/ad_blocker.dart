import 'dart:async';
import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AdBlocker {
  static final AdBlocker _instance = AdBlocker._internal();
  factory AdBlocker() => _instance;
  AdBlocker._internal();

  final List<String> _filterLists = [
    // uBlock Origin lists
    'https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt',
    'https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt',
    'https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt',
    'https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/resource-abuse.txt',
    'https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt',
    
    // Malwack Module Lists
    'https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt',
    'https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext',
    
    // Additional Lists
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts',
    'https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt',
    'https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_15_DnsFilter/filter.txt',
  ];

  final Set<String> _blockedDomains = {};
  final Set<String> _whitelist = {};
  bool _isInitialized = false;
  late ContentBlockerHandler _contentBlockerHandler;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadFilters();
    _setupContentBlocker();
    _isInitialized = true;

    // Schedule periodic updates
    Timer.periodic(Duration(days: 1), (_) => _updateFilters());
  }

  Future<void> _loadFilters() async {
    final directory = await getApplicationDocumentsDirectory();
    final filtersFile = File('${directory.path}/filters.json');

    if (await filtersFile.exists()) {
      final content = await filtersFile.readAsString();
      final data = json.decode(content);
      _blockedDomains.addAll(Set<String>.from(data['blocked'] ?? []));
      _whitelist.addAll(Set<String>.from(data['whitelist'] ?? []));
    } else {
      await _updateFilters();
    }
  }

  Future<void> _updateFilters() async {
    for (final url in _filterLists) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          _parseFilterList(response.body);
        }
      } catch (e) {
        print('Error updating filter list from $url: $e');
      }
    }

    await _saveFilters();
    _setupContentBlocker();
  }

  void _parseFilterList(String content) {
    final lines = content.split('\n');
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('!') || line.startsWith('#')) continue;

      if (line.startsWith('@@')) {
        // Whitelist entry
        final domain = _extractDomain(line.substring(2));
        if (domain != null) _whitelist.add(domain);
      } else {
        // Blocked domain
        final domain = _extractDomain(line);
        if (domain != null) _blockedDomains.add(domain);
      }
    }
  }

  String? _extractDomain(String rule) {
    if (rule.startsWith('||')) {
      rule = rule.substring(2);
    }
    
    final domainPattern = RegExp(r'^([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})');
    final match = domainPattern.firstMatch(rule);
    return match?.group(1);
  }

  Future<void> _saveFilters() async {
    final directory = await getApplicationDocumentsDirectory();
    final filtersFile = File('${directory.path}/filters.json');
    
    await filtersFile.writeAsString(json.encode({
      'blocked': _blockedDomains.toList(),
      'whitelist': _whitelist.toList(),
      'lastUpdated': DateTime.now().toIso8601String(),
    }));
  }

  void _setupContentBlocker() {
    _contentBlockerHandler = ContentBlockerHandler([
      ContentBlocker(
        trigger: ContentBlockerTrigger(
          urlFilter: _blockedDomains.map((domain) => "*$domain*").join('|'),
          resourceType: [
            ContentBlockerResourceType.IMAGE,
            ContentBlockerResourceType.STYLE_SHEET,
            ContentBlockerResourceType.SCRIPT,
            ContentBlockerResourceType.DOCUMENT,
            ContentBlockerResourceType.RAW,
            ContentBlockerResourceType.FONT,
          ],
        ),
        action: ContentBlockerAction(
          type: ContentBlockerActionType.BLOCK,
        ),
      ),
      // Whitelist rules
      ..._whitelist.map((domain) => ContentBlocker(
        trigger: ContentBlockerTrigger(
          urlFilter: "*$domain*",
          resourceType: [ContentBlockerResourceType.DOCUMENT],
        ),
        action: ContentBlockerAction(
          type: ContentBlockerActionType.IGNORE_PREVIOUS_RULES,
        ),
      )),
    ]);
  }

  ContentBlockerHandler get contentBlockerHandler => _contentBlockerHandler;

  // JavaScript injection for additional blocking
  String get injectedScript => '''
    (function() {
      const blockedSelectors = [
        'div[class*="ad-"]',
        'div[class*="ads-"]',
        'div[id*="google_ads"]',
        'iframe[src*="doubleclick.net"]',
        'div[class*="sponsored"]',
        'div[class*="promotion"]',
        // Add more CSS selectors as needed
      ];

      function removeAds() {
        const elements = document.querySelectorAll(blockedSelectors.join(','));
        elements.forEach(el => el.remove());
      }

      // Initial cleanup
      removeAds();

      // Watch for new elements
      const observer = new MutationObserver(() => removeAds());
      observer.observe(document.body, {
        childList: true,
        subtree: true
      });

      // Block common ad-related scripts
      const originalAppend = Element.prototype.appendChild;
      Element.prototype.appendChild = function(node) {
        if (node.nodeName === 'SCRIPT' && 
            node.src && 
            (node.src.includes('ads') || 
             node.src.includes('analytics') || 
             node.src.includes('tracker'))) {
          return node;
        }
        return originalAppend.call(this, node);
      };
    })();
  ''';

  // Extension support (basic implementation)
  Future<void> installExtension(String crxUrl) async {
    // This is a placeholder for extension support
    // Full implementation would require:
    // 1. Downloading and parsing CRX files
    // 2. Implementing Chrome Extension API compatibility layer
    // 3. Managing extension lifecycle and permissions
    throw UnimplementedError('Extension support is under development');
  }
}
