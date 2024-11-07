import 'package:phoenix_socket/phoenix_socket.dart';
import 'dart:async';

class BrowserService {
  late PhoenixSocket socket;
  late PhoenixChannel browserChannel;
  final String userId;

  BrowserService({required this.userId}) {
    _initSocket();
  }

  void _initSocket() {
    socket = PhoenixSocket('ws://localhost:4000/socket',
        socketOptions: PhoenixSocketOptions(
          params: {'user_id': userId},
        ));

    browserChannel = socket.channel('browser:$userId');
    
    browserChannel.onMessage('tab_created', (payload, _ref, _joinRef) {
      // Handle new tab creation
    });

    browserChannel.onMessage('settings_updated', (payload, _ref, _joinRef) {
      // Handle settings updates
    });

    socket.connect();
    browserChannel.join();
  }

  Future<Map<String, dynamic>> createTab(String url) async {
    final response = await browserChannel.push('new_tab', {'url': url});
    if (response.isError) {
      throw Exception('Failed to create tab: ${response.response}');
    }
    return response.response as Map<String, dynamic>;
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    final response = await browserChannel.push('update_settings', settings);
    if (response.isError) {
      throw Exception('Failed to update settings: ${response.response}');
    }
  }
}
