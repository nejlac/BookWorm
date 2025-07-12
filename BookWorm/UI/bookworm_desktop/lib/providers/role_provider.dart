import 'package:bookworm_desktop/model/genre.dart';
import 'package:bookworm_desktop/model/role.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bookworm_desktop/providers/auth_provider.dart';

class RoleProvider extends ChangeNotifier {
  static String? _baseUrl;
  RoleProvider() {
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

  Future<List<Role>> getAllRoles() async {
    final url = "$_baseUrl/Role";
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: createHeaders());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('Role API response: ' + data.toString());

      if (data is Map && data.containsKey('items')) {
        final items = data['items'];
        if (items is List) {
          return List<Role>.from(items.map((e) => Role.fromJson(e)));
        } else {
          return [];
        }
      }

      if (data is List) {
        return List<Role>.from(data.map((e) => Role.fromJson(e)));
      } else {
        throw Exception("Unexpected role response format");
      }
    } else {
      throw Exception("Failed to load roles: "+response.statusCode.toString());
    }
  }
}
