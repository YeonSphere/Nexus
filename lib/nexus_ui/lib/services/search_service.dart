import 'package:dio/dio.dart';

class SearchService {
  final Dio _dio;
  final String _searchEngine;

  SearchService({
    Dio? dio,
    String searchEngine = 'https://search.brave.com/api/suggest?q=',
  })  : _dio = dio ?? Dio(),
        _searchEngine = searchEngine;

  Future<List<String>> getSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _dio.get('$_searchEngine$query');
      if (response.data is List && response.data.length > 1) {
        final suggestions = response.data[1] as List;
        return suggestions.cast<String>();
      }
      return [];
    } catch (e) {
      print('Error getting search suggestions: $e');
      return [];
    }
  }

  Future<bool> isValidUrl(String url) async {
    if (url.isEmpty) return false;

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    try {
      final response = await _dio.head(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  String getSearchUrl(String query) {
    if (isValidUrl(query)) {
      return query.startsWith('http') ? query : 'https://$query';
    }
    return '$_searchEngine$query';
  }
}
