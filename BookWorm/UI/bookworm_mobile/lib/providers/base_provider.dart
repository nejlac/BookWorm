import 'dart:convert';

import 'package:bookworm_mobile/model/search_result.dart';
import 'package:bookworm_mobile/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

abstract class BaseProvider<T> with ChangeNotifier {
  static String? baseUrl;
  String _endpoint = "";

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
   baseUrl = const String.fromEnvironment("baseUrl",
    defaultValue: "http://10.0.2.2:7031/api/");
    print("BASE URL IN USE: $baseUrl");
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$baseUrl$_endpoint";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

  
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);
    print("DEBUG: Response status: ${response.statusCode}");
    print("DEBUG: Response body: ${response.body}");

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      print("DEBUG: Parsed data: $data");
      print("DEBUG: data type: ${data.runtimeType}");
      
      var result = SearchResult<T>();
      
     
      if (data is Map<String, dynamic>) {
       
        print("DEBUG: Paginated response detected");
        result.totalCount = data['totalCount'];
        result.page = data['page'];
        result.pageSize = data['pageSize'];
        
        if (data['items'] != null) {
          result.items = List<T>.from(data["items"].map((e) => fromJson(e)));
        } else {
          result.items = [];
        }
      } else if (data is List) {
      
        print("DEBUG: Direct array response detected");
        result.totalCount = data.length;
        result.page = 0;
        result.pageSize = data.length;
        result.items = List<T>.from(data.map((e) => fromJson(e)));
      } else {
        print("DEBUG: Unexpected response format: ${data.runtimeType}");
        result.items = [];
      }

      return result;
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<T> insert(dynamic request) async {
    var url = "$baseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
  
      throw new Exception("Insert failed: ${response.statusCode} - ${response.body}");
    }
  }

  Future<T> update(int id, [dynamic request]) async {
    var url = "$baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {

      throw new Exception("Update failed: ${response.statusCode} - ${response.body}");
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(http.Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw new Exception("Unauthorized");
    } else {
      print("Response body: ${response.body}");
      // Preserve the actual error response from the backend
      throw new Exception("${response.statusCode} - ${response.body}");
    }
  }

  Map<String, String> createHeaders() {
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";

   print("passed creds: $username, $password");

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth
    };

    return headers;
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

  Future<void> delete(int id) async {
    var url = "$baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);

    if (isValidResponse(response)) {
      return;
    } else {
      throw new Exception("Unknown error");
    }
  }
}