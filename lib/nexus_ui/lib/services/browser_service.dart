import 'package:phoenix_socket/phoenix_socket.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final browserServiceProvider = Provider((ref) => BrowserService());

class BrowserService {
  late PhoenixSocket socket;
  late PhoenixChannel browserChannel;
  String? userId;

  Future<void> connect() async {
    socket = PhoenixSocket('ws://localhost:4000/socket');
    userId = DateTime.now().millisecondsSinceEpoch.toString();
    
    browserChannel = socket.channel('browser:$userId');
    
    socket.connect();
    
    try {
      await browserChannel.join();
    } catch (e) {
      print('Failed to join channel: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createTab(String url) async {
    final response = await browserChannel.push('new_tab', {'url': url});
    if (response.isError) {
      throw Exception('Failed to create tab: ${response.response}');
    }
    return response.response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> navigateTab(String tabId, String url) async {
    final response = await browserChannel.push('navigate', {
      'tab_id': tabId,
      'url': url
    });
    if (response.isError) {
      throw Exception('Failed to navigate: ${response.response}');
    }
    return response.response as Map<String, dynamic>;
  }

  void dispose() {
    browserChannel.leave();
    socket.disconnect();
  }
}
