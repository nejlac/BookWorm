
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