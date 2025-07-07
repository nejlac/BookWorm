import 'package:bookworm_desktop/model/author.dart';
import 'package:bookworm_desktop/providers/base_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthorProvider extends BaseProvider<Author> {
  AuthorProvider():super("author");

  @override
  Author fromJson(dynamic json) {
    return Author.fromJson(json);
  }
  
  Future<List<Author>> getAllAuthors() async {
    try {
      final result = await get();
      return result.items ?? [];
    } catch (e) {
      print('Error fetching authors: $e');
      return [];
    }
  }

  Future<void> uploadPhoto(int authorId, File photoFile) async {
    try {
      print("Uploading author photo. File path: "+photoFile.path);
      var url = "${BaseProvider.baseUrl ?? "https://localhost:7031/api/"}author/$authorId/cover";
      print("Upload URL: $url");
      var uri = Uri.parse(url);
      var request = http.MultipartRequest('POST', uri);
      var headers = createHeaders();
      headers.remove('Content-Type');
      request.headers.addAll(headers);
      var stream = http.ByteStream(photoFile.openRead());
      var length = await photoFile.length();
      var filename = photoFile.path.split('/').last;
      print("Creating multipart file: $filename, size: $length");
      var multipartFile = http.MultipartFile(
        'coverImage',
        stream,
        length,
        filename: filename,
      );
      request.files.add(multipartFile);
      print("Sending request...");
      var streamedResponse = await request.send();
      print("Response status: streamedResponse.statusCode");
      var response = await http.Response.fromStream(streamedResponse);
      print("Response body: response.body");
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print("Upload failed with status: response.statusCode");
        print("Response body: response.body");
        throw Exception("Failed to upload author photo: response.statusCode - response.body");
      }
      print("Upload successful!");
    } catch (e) {
      print("Error in uploadPhoto: $e");
      rethrow;
    }
  }

  Future<Author> getById(int id) async {
    var url = "${BaseProvider.baseUrl ?? "https://localhost:7031/api/"}author/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var data = jsonDecode(response.body);
      print("Author getById response: $data");
      return fromJson(data);
    } else {
      throw Exception("Failed to get author: \\${response.statusCode} - \\${response.body}");
    }
  }

  Future<bool> delete(int id) async {
    var url = "${BaseProvider.baseUrl ?? "https://localhost:7031/api/"}author/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.delete(uri, headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      print("Failed to delete author: \\${response.statusCode} - \\${response.body}");
      return false;
    }
  }
} 