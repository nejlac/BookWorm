import 'dart:convert';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/country.dart';
import 'auth_provider.dart';

class CountryProvider extends ChangeNotifier {
  
  CountryProvider() {
  }
  String get _baseUrl => BaseProvider.baseUrl!;
  List<Country> _countries = [];
  List<Country> get countries => _countries;

  Future<void> fetchCountries() async {
    final url = Uri.parse('${_baseUrl}Country?pageSize=500');
    
    // Use the same authentication pattern as BaseProvider
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";
    
    print("CountryProvider - passed creds: $username, $password");
    
    String basicAuth = "Basic ${base64Encode(utf8.encode('$username:$password'))}";
    
    final headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth
    };
    
    final response = await http.get(url, headers: headers);
  
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('items')) {
        final items = data['items'] as List;
        _countries = items.map((e) => Country.fromJson(e)).toList();
      } else if (data is List) {
        _countries = data.map((e) => Country.fromJson(e)).toList();
      } else {
        throw Exception('Unexpected country response format');
      }
      notifyListeners();
    } else {
      throw Exception('Failed to load countries: ${response.statusCode}');
    }
  }
} 