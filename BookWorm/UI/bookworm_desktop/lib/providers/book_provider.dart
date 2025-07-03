import 'package:bookworm_desktop/model/book.dart';
import 'package:bookworm_desktop/model/search_result.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bookworm_desktop/providers/auth_provider.dart';
import 'dart:convert';

class BookProvider extends ChangeNotifier {
  static String? _baseUrl;
  BookProvider() {
    _baseUrl = const String.fromEnvironment("baseUrl", defaultValue: "https://localhost:7031/api");
  }
   Future<SearchResult<Book>> get({dynamic filter}) async {
    var url = "$_baseUrl/book";
    print("filter: $filter");
    if (filter != null) {
      var query = getQueryString(filter);
      print("query: $query");
      url += "?$query";
    }
    print("url: $url");
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: createHeaders());
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      var searchResult = SearchResult<Book>();
      searchResult.totalCount = data["totalCount"];
      searchResult.page = data["page"];
      searchResult.pageSize = data["pageSize"];
      searchResult.items = List<Book>.from(data["items"].map((e) => Book.fromJson(e)));
      return searchResult;
    } else {
      throw Exception("Something went wrong, please try again later!");
    }
  }

  String getQueryString(Map params) {
    final queryParams = <String>[];
    params.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      if (value is List || value is Map) return; 
      String encodedKey = Uri.encodeQueryComponent(key.toString());
      String encodedValue = value is String
          ? Uri.encodeQueryComponent(value)
          : value.toString();
      queryParams.add('$encodedKey=$encodedValue');
    });
    return queryParams.join('&');
  }

  }
   bool isValidResponse(http.Response response) {
    if (response.statusCode <= 299) {
      return true;
    }
    else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    }
    else {
      throw Exception("Something went wrong, please try again later!");
    }
  }

  Map<String, String> createHeaders() {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('${AuthProvider.username}:${AuthProvider.password}'))}';
    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };
    return headers;
  }
