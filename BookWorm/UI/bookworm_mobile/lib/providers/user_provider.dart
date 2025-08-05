
import 'package:bookworm_mobile/model/user.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProvider extends BaseProvider<User> {
  UserProvider():super("users");

  @override
  User fromJson(dynamic json) {
    return User.fromJson(json);
  }
  String get baseUrl => BaseProvider.baseUrl!;

  Future<User?> login(String username, String password) async {
    try {
      var url = "${BaseProvider.baseUrl!}users/login";
      var uri = Uri.parse(url);
      
      var requestBody = jsonEncode({
        'username': username,
        'password': password,
      });
      
      var headers = createHeaders();
      headers['Content-Type'] = 'application/json';
      
      var response = await http.post(uri, headers: headers, body: requestBody);
      
      // Debug logging
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception("Invalid username or password");
      } else if (response.statusCode == 403) {
        throw Exception("Access denied. Only users with 'User' role can access the mobile app.");
      } else if (response.statusCode == 500) {
        // Try to parse error message from response body for server errors
        try {
          var errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            throw Exception(errorData['message']);
          } else {
            throw Exception("Server error. Please try again later.");
          }
        } catch (parseError) {
          throw Exception("Server error. Please try again later.");
        }
      } else {
        // Try to parse error message from response body for other status codes
        try {
          var errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            throw Exception(errorData['message']);
          } else {
            throw Exception("Login failed. Please try again.");
          }
        } catch (parseError) {
          throw Exception("Login failed. Please try again.");
        }
      }
    } catch (e) {
      // Debug logging for the exception
      print("Exception caught: ${e.toString()}");
      print("Exception type: ${e.runtimeType}");
      
      // Handle network errors and other exceptions
      if (e.toString().contains('SocketException') || e.toString().contains('Connection')) {
        throw Exception("Network error. Please check your connection and try again.");
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception("Request timeout. Please try again.");
      } else {
        // For other exceptions, preserve the original error message without "Exception:" prefix
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring('Exception: '.length);
        }
        throw Exception(errorMessage);
      }
    }
  }
  

  
  Future<void> uploadPhoto(int userId, File photoFile) async {
    try {
      var url = "${BaseProvider.baseUrl!}users/$userId/cover";
     
      var uri = Uri.parse(url);
      var request = http.MultipartRequest('POST', uri);
      var headers = createHeaders();
      headers.remove('Content-Type');
      request.headers.addAll(headers);
      var stream = http.ByteStream(photoFile.openRead());
      var length = await photoFile.length();
      var filename = photoFile.path.split('/').last;
      var multipartFile = http.MultipartFile(
        'coverImage',
        stream,
        length,
        filename: filename,
      );
      request.files.add(multipartFile);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception("Failed to upload user photo: response.statusCode - response.body");
      }
    
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getById(int id) async {
    var url = "${BaseProvider.baseUrl!}users/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to get user: \\${response.statusCode} - \\${response.body}");
    }
  }

  Future<List<User>> getRecommendedFriends(int userId) async {
    try {
      final url = '${baseUrl}Users/recommend-friends/$userId';
      final uri = Uri.parse(url);
      
      final response = await http.get(uri, headers: createHeaders());
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recommended users: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(int id) async {
    var url = "${BaseProvider.baseUrl!}users/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.delete(uri, headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      return false;
    }
  }

 
} 