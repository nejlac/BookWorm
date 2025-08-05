import 'package:bookworm_desktop/model/genre.dart';
import 'package:bookworm_desktop/model/search_result.dart';
import 'package:bookworm_desktop/providers/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GenreProvider extends BaseProvider<Genre> {
  GenreProvider() : super("Genre");

  List<Genre>? _allGenresCache;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  @override
  Genre fromJson(data) {
    return Genre.fromJson(data);
  }
  Future<List<Genre>> getAllGenresForDropdown() async {
    if (_allGenresCache != null && _cacheTimestamp != null) {
      final now = DateTime.now();
      if (now.difference(_cacheTimestamp!) < _cacheValidDuration) {
        return _allGenresCache!;
      }
    }

    try {
      final result = await get(filter: {'pageSize': 1000, 'page': 0});
      _allGenresCache = result.items ?? [];
      _cacheTimestamp = DateTime.now();
      return _allGenresCache!;
    } catch (e) {
      if (_allGenresCache != null) {
        return _allGenresCache!;
      }
      rethrow;
    }
  }

  Future<SearchResult<Genre>> getGenresPaginated({int? page, int? pageSize}) async {
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

  Future<SearchResult<Genre>> getGenresForList({int? page, int? pageSize}) async {
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

  Future<List<Genre>> getAllGenres() async {
    return await getAllGenresForDropdown();
  }

  Future<SearchResult<Genre>> getGenres({int? page, int? pageSize}) async {
    return await getGenresPaginated(page: page, pageSize: pageSize);
  }

  Future<Genre> createGenre(String name, String? description) async {
    final request = {
      'name': name,
      'description': description,
    };
    final result = await insert(request);
    
    _allGenresCache = null;
    _cacheTimestamp = null;
    
    return result;
  }

  Future<Genre> updateGenre(int id, String name, String? description) async {
    final request = {
      'name': name,
      'description': description,
    };
    final result = await update(id, request);
    
    _allGenresCache = null;
    _cacheTimestamp = null;
    
    return result;
  }

  @override
  Future<String?> delete(int id) async {
    try {
      var url = "${BaseProvider.baseUrl}Genre/$id";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      var response = await http.delete(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _allGenresCache = null;
        _cacheTimestamp = null;
        return null; 
      } else {
        try {
          var errorData = jsonDecode(response.body);
          return errorData['message'] ?? 'Cannot delete genre who is linked to one or more books.';
        } catch (e) {
          return 'Cannot delete genre who is linked to one or more books.';
        }
      }
    } catch (e) {
      return e.toString();
    }
  }

  void clearCache() {
    _allGenresCache = null;
    _cacheTimestamp = null;
  }
}
