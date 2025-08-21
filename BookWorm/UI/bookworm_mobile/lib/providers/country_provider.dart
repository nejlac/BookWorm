import 'dart:convert';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import '../model/country.dart';

class CountryProvider extends BaseProvider<Country> {
  CountryProvider() : super("Country");
  
  @override
  Country fromJson(dynamic json) {
    return Country.fromJson(json);
  }
  String get baseUrl => BaseProvider.baseUrl!;

  List<Country> _countries = [];
  List<Country> get countries => _countries;

  Future<void> fetchCountries() async {
    try {
      final url = Uri.parse('${baseUrl}Country?pageSize=500');
      
      final headers = {
        "Content-Type": "application/json",
      };
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map && data.containsKey('items')) {
          final items = data['items'] as List;
          _countries = items.map((e) {
            if (e == null) {
              return null;
            }
            try {
              return Country.fromJson(e as Map<String, dynamic>);
            } catch (parseError) {
              return null;
            }
          }).where((country) => country != null).cast<Country>().toList();
        } else if (data is List) {
          _countries = data.map((e) {
            if (e == null) {
              return null;
            }
            try {
              return Country.fromJson(e as Map<String, dynamic>);
            } catch (parseError) {
              return null;
            }
          }).where((country) => country != null).cast<Country>().toList();
        } else {
          throw Exception('Unexpected country response format');
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
} 