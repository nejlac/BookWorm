import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bookworm_desktop/providers/auth_provider.dart';

class GenreProvider extends ChangeNotifier {
  static String? _baseUrl;
  GenreProvider() {
    _baseUrl = const String.fromEnvironment("baseUrl", defaultValue: "https://localhost:7031/api");
  }

  Map<String, String> createHeaders() {
    String basicAuth = 'Basic '
        + base64Encode(utf8.encode('${AuthProvider.username}:${AuthProvider.password}'));
    return {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };
  }

  Future<List<Map<String, dynamic>>> getAllGenres() async {
    final url = "$_baseUrl/Genre";
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: createHeaders());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('Genre API response: ' + data.toString());
      if (data is Map && data.containsKey('items')) {
        final items = data['items'];
        if (items is List && items.isNotEmpty && items.first is Map && items.first.containsKey('name')) {
          return List<Map<String, dynamic>>.from(items);
        } else {
          return [];
        }
      }
      if (data is List) {
        if (data.isNotEmpty && data.first is Map && data.first.containsKey('name')) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          return [];
        }
      } else {
        throw Exception("Unexpected genre response format");
      }
    } else {
      throw Exception("Failed to load genres: "+response.statusCode.toString());
    }
  }
}
