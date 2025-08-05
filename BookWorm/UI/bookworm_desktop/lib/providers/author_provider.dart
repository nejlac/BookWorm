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
  String get baseUrl => BaseProvider.baseUrl ?? "https://localhost:7031/api/";
  Future<List<Author>> getAllAuthors() async {
    try {
      final result = await get(filter: {'RetrieveAll': true});
      return result.items ?? [];
    } catch (e) {
      print('Error fetching authors: $e');
      return [];
    }
  }

   Future<void> accept(int id) async {
    var url = "${baseUrl}author/$id/accept";
    var headers = createHeaders();
    var response = await http.post(Uri.parse(url), headers: headers);
    if (!isValidResponse(response)) {
      throw Exception("Failed to accept author");
    }
  }

  Future<void> decline(int id) async {
    var url = "${baseUrl}author/$id/decline";
    var headers = createHeaders();
    var response = await http.post(Uri.parse(url), headers: headers);
    if (!isValidResponse(response)) {
      throw Exception("Failed to decline author");
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

  Future<String?> delete(int id) async {
    try {
      var url = "${BaseProvider.baseUrl ?? "https://localhost:7031/api/"}author/$id";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      var response = await http.delete(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null; // Success, no error message
      } else {
        print("Failed to delete author: ${response.statusCode} - ${response.body}");
        // Parse the error message from the response
        try {
          var errorData = jsonDecode(response.body);
          return errorData['message'] ?? 'Cannot delete author who is linked to one or more books.';
        } catch (e) {
          return 'Cannot delete author who is linked to one or more books.';
        }
      }
    } catch (e) {
      print("Exception during author deletion: $e");
      return e.toString();
    }
  }

  Future<bool> existsWithNameAndDateOfBirth(String name, DateTime dateOfBirth, {int? excludeId}) async {
    final filter = {
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'pageSize': 1,
      'page': 0,
    };
    final authors = await get(filter: filter);
    if (authors.items == null || authors.items!.isEmpty) return false;
    if (excludeId != null) {
      return authors.items!.any((a) => a.id != excludeId);
    }
    return true;
  }
} 