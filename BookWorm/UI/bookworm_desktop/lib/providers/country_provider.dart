import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/country.dart';
import '../model/search_result.dart';
import 'base_provider.dart';

class CountryProvider extends BaseProvider<Country> {
  CountryProvider() : super("Country");

  List<Country> _countries = [];
  List<Country> get countries => _countries;

  // Cache for all countries (used in dropdowns)
  List<Country>? _allCountriesCache;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  @override
  Country fromJson(data) {
    return Country.fromJson(data);
  }

  Future<List<Country>> getAllCountriesForDropdown() async {
    if (_allCountriesCache != null && _cacheTimestamp != null) {
      final now = DateTime.now();
      if (now.difference(_cacheTimestamp!) < _cacheValidDuration) {
        return _allCountriesCache!;
      }
    }

    try {
      final result = await get(filter: {'pageSize': 1000, 'page': 0});
      _allCountriesCache = result.items ?? [];
      _cacheTimestamp = DateTime.now();
      return _allCountriesCache!;
    } catch (e) {
      if (_allCountriesCache != null) {
        return _allCountriesCache!;
      }
      rethrow;
    }
  }

  // Method for country list screen - gets paginated countries
  Future<SearchResult<Country>> getCountriesPaginated({int? page, int? pageSize}) async {
    final filter = <String, dynamic>{};
    if (page != null) filter['page'] = page;
    else {
      filter['page'] = 0; // Default to first page if not specified
    }
    if (pageSize != null) {
      filter['pageSize'] = pageSize;
    } else {
      filter['pageSize'] = 10; // Default page size for list view
    }
    
    return await get(filter: filter);
  }

  // Method for country list screen - gets paginated countries with 0-based indexing
  Future<SearchResult<Country>> getCountriesForList({int? page, int? pageSize}) async {
    final filter = <String, dynamic>{};
    if (page != null) filter['page'] = page - 1; // Convert to 0-based indexing
    else {
      filter['page'] = 0; // Default to first page (0-based indexing)
    }
    if (pageSize != null) {
      filter['pageSize'] = pageSize;
    } else {
      filter['pageSize'] = 10; // Default page size for list view
    }
    
    return await get(filter: filter);
  }

  // Legacy method for backward compatibility
  Future<void> fetchCountries() async {
    final result = await get();
    _countries = result.items ?? [];
    notifyListeners();
  }

  // Legacy method for backward compatibility
  Future<SearchResult<Country>> getCountries({int? page, int? pageSize}) async {
    return await getCountriesPaginated(page: page, pageSize: pageSize);
  }

  // Legacy method for backward compatibility
  Future<SearchResult<Country>> getAllCountries() async {
    return await get(filter: {'pageSize': 500, 'page': 0});
  }

  Future<Country> createCountry(String name) async {
    final request = {
      'name': name,
    };
    final result = await insert(request);
    
    // Invalidate cache when new country is created
    _allCountriesCache = null;
    _cacheTimestamp = null;
    
    return result;
  }

  Future<Country> updateCountry(int id, String name) async {
    final request = {
      'name': name,
    };
    final result = await update(id, request);
    
    // Invalidate cache when country is updated
    _allCountriesCache = null;
    _cacheTimestamp = null;
    
    return result;
  }

  @override
  Future<String?> delete(int id) async {
    try {
      var url = "${BaseProvider.baseUrl ?? "http://localhost:7031/api/"}Country/$id";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      var response = await http.delete(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Invalidate cache when country is deleted
        _allCountriesCache = null;
        _cacheTimestamp = null;
        return null; // Success, no error message
      } else {
        print("Failed to delete country: ${response.statusCode} - ${response.body}");
        // Parse the error message from the response
        try {
          var errorData = jsonDecode(response.body);
          return errorData['message'] ?? 'Cannot delete country who is linked to one or more authors or users.';
        } catch (e) {
          return 'Cannot delete country who is linked to one or more authors or users.';
        }
      }
    } catch (e) {
      print("Exception during country deletion: $e");
      return e.toString();
    }
  }

  // Clear cache manually if needed
  void clearCache() {
    _allCountriesCache = null;
    _cacheTimestamp = null;
  }
} 