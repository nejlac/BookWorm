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
  String get baseUrl => BaseProvider.baseUrl!;
  Future<List<Author>> getAllAuthors() async {
    try {
      final result = await get(filter: {'RetrieveAll': true});
      return result.items ?? [];
    } catch (e) {
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
      var url = "${BaseProvider.baseUrl}author/$authorId/cover";
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
       
        throw Exception("Failed to upload author photo: response.statusCode - response.body");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Author> getById(int id) async {
    var url = "${BaseProvider.baseUrl}author/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to get author: \\${response.statusCode} - \\${response.body}");
    }
  }

  Future<String?> delete(int id) async {
    try {
      var url = "${BaseProvider.baseUrl}author/$id";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      var response = await http.delete(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null; 
      } else {
        try {
          var errorData = jsonDecode(response.body);
          return errorData['message'] ?? 'Cannot delete author who is linked to one or more books.';
        } catch (e) {
          return 'Cannot delete author who is linked to one or more books.';
        }
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> existsWithNameAndDateOfBirth(String name, DateTime dateOfBirth, {int? excludeId}) async {
    try {
      final filter = {
        'name': name,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'pageSize': 100, 
        'page': 0,
      };
      final authors = await get(filter: filter);
      if (authors.items == null || authors.items!.isEmpty) return false;
      
      final matchingAuthors = authors.items!.where((author) => 
        author.name.toLowerCase().trim() == name.toLowerCase().trim() &&
        author.dateOfBirth.year == dateOfBirth.year &&
        author.dateOfBirth.month == dateOfBirth.month &&
        author.dateOfBirth.day == dateOfBirth.day
      ).toList();
      
      if (matchingAuthors.isEmpty) return false;
      
      if (excludeId != null) {
        return matchingAuthors.any((a) => a.id != excludeId);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
} 