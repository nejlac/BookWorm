import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/country.dart';
import '../model/search_result.dart';
import 'base_provider.dart';

class CountryProvider extends BaseProvider<Country> {
  CountryProvider() : super("Country");

  List<Country> _countries = [];
  List<Country> get countries => _countries;

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

  Future<SearchResult<Country>> getCountriesPaginated({int? page, int? pageSize}) async {
    final filter = <String, dynamic>{};
    if (page != null) filter['page'] = page;
    else {
      filter['page'] = 0; 
    }
    if (pageSize != null) {
      filter['pageSize'] = pageSize;
    } else {
      filter['pageSize'] = 10; 
    }
    
    return await get(filter: filter);
  }

  Future<SearchResult<Country>> getCountriesForList({int? page, int? pageSize}) async {
    final filter = <String, dynamic>{};
    if (page != null) filter['page'] = page - 1; 
    else {
      filter['page'] = 0; 
    }
    if (pageSize != null) {
      filter['pageSize'] = pageSize;
    } else {
      filter['pageSize'] = 10; 
    }
    
    return await get(filter: filter);
  }

  Future<void> fetchCountries() async {
    final result = await get();
    _countries = result.items ?? [];
    notifyListeners();
  }

  Future<SearchResult<Country>> getCountries({int? page, int? pageSize}) async {
    return await getCountriesPaginated(page: page, pageSize: pageSize);
  }

  Future<SearchResult<Country>> getAllCountries() async {
    return await get(filter: {'pageSize': 500, 'page': 0});
  }

  Future<Country> createCountry(String name) async {
    final request = {
      'name': name,
    };
    final result = await insert(request);
    
    _allCountriesCache = null;
    _cacheTimestamp = null;
    
    return result;
  }

  Future<Country> updateCountry(int id, String name) async {
    final request = {
      'name': name,
    };
    final result = await update(id, request);
    
    _allCountriesCache = null;
    _cacheTimestamp = null;
    
    return result;
  }

  @override
  Future<String?> delete(int id) async {
    try {
      var url = "${BaseProvider.baseUrl}Country/$id";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      var response = await http.delete(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _allCountriesCache = null;
        _cacheTimestamp = null;
        return null; 
      } else {
        print("Failed to delete country: ${response.statusCode} - ${response.body}");
      
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

  void clearCache() {
    _allCountriesCache = null;
    _cacheTimestamp = null;
  }
} 