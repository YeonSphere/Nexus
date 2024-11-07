import 'package:phoenix_socket/phoenix_socket.dart';

class HistoryService {
  final PhoenixChannel _channel;

  HistoryService(this._channel);

  Future<List<Map<String, dynamic>>> getHistory() async {
    final response = await _channel.push('get_history', {});
    if (response.isError) {
      throw Exception('Failed to get history: ${response.response}');
    }
    return List<Map<String, dynamic>>.from(response.response['history']);
  }

  Future<void> addToHistory(String url, String title, String? favicon) async {
    final response = await _channel.push('add_entry', {
      'url': url,
      'title': title,
      'favicon': favicon,
    });
    if (response.isError) {
      throw Exception('Failed to add history entry: ${response.response}');
    }
  }

  Future<void> clearHistory() async {
    final response = await _channel.push('clear_history', {});
    if (response.isError) {
      throw Exception('Failed to clear history: ${response.response}');
    }
  }

  Stream<Map<String, dynamic>> onHistoryUpdate() {
    return _channel.messages.where((event) => event.event == 'history_updated')
        .map((event) => event.payload as Map<String, dynamic>);
  }
}
