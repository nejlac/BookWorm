import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/country.dart';
import 'auth_provider.dart';

class CountryProvider extends ChangeNotifier {
  static String? _baseUrl;
  CountryProvider() {
    _baseUrl = const String.fromEnvironment("baseUrl", defaultValue: "http://10.0.2.2:7031/api");
  }

  List<Country> _countries = [];
  List<Country> get countries => _countries;

  Future<void> fetchCountries() async {
    final url = Uri.parse('${_baseUrl}Country?pageSize=500');
    final headers = <String, String>{};
    if (AuthProvider.username != null && AuthProvider.password != null) {
      String basicAuth = 'Basic ' + base64Encode(utf8.encode('${AuthProvider.username}:${AuthProvider.password}'));
      headers['Authorization'] = basicAuth;
    }
    final response = await http.get(url, headers: headers);
  
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('items')) {
        final items = data['items'] as List;
        _countries = items.map((e) => Country.fromJson(e)).toList();
      } else if (data is List) {
        _countries = data.map((e) => Country.fromJson(e)).toList();
      } else {
        print('===COUNTRY=== Unexpected country response format: ${data.runtimeType}');
        throw Exception('Unexpected country response format');
      }
      notifyListeners();
    } else {
      print('===COUNTRY=== Failed to load countries: ${response.statusCode}');
      throw Exception('Failed to load countries: ${response.statusCode}');
    }
  }
} 