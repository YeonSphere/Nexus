import 'package:phoenix_socket/phoenix_socket.dart';
import 'package:shared_preferences.dart';

class SyncService {
  final PhoenixChannel _channel;
  final SharedPreferences _prefs;
  final String userId;

  SyncService({
    required this.userId,
    required PhoenixChannel channel,
    required SharedPreferences prefs,
  })  : _channel = channel,
        _prefs = prefs;

  Future<void> syncBookmarks() async {
    final response = await _channel.push('sync_bookmarks', {
      'user_id': userId,
      'last_sync': _prefs.getString('last_bookmark_sync'),
    });

    if (response.isError) {
      throw Exception('Failed to sync bookmarks: ${response.response}');
    }

    await _prefs.setString('last_bookmark_sync', DateTime.now().toIso8601String());
  }

  Future<void> syncHistory() async {
    final response = await _channel.push('sync_history', {
      'user_id': userId,
      'last_sync': _prefs.getString('last_history_sync'),
    });

    if (response.isError) {
      throw Exception('Failed to sync history: ${response.response}');
    }

    await _prefs.setString('last_history_sync', DateTime.now().toIso8601String());
  }

  Future<void> syncSettings() async {
    final response = await _channel.push('sync_settings', {
      'user_id': userId,
      'last_sync': _prefs.getString('last_settings_sync'),
    });

    if (response.isError) {
      throw Exception('Failed to sync settings: ${response.response}');
    }

    await _prefs.setString('last_settings_sync', DateTime.now().toIso8601String());
  }

  Stream<Map<String, dynamic>> onSyncUpdate() {
    return _channel.messages
        .where((event) => event.event.startsWith('sync_'))
        .map((event) => event.payload as Map<String, dynamic>);
  }

  Future<void> syncAll() async {
    await Future.wait([
      syncBookmarks(),
      syncHistory(),
      syncSettings(),
    ]);
  }
}
