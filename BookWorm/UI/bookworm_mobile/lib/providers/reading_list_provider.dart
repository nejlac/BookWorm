import 'package:bookworm_mobile/model/reading_list.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ReadingListProvider extends BaseProvider<ReadingList> {
  ReadingListProvider():super("ReadingList");

  @override
  ReadingList fromJson(dynamic json) {
    return ReadingList.fromJson(json);
  }

  String get baseUrl => BaseProvider.baseUrl ?? "http://10.0.2.2:7031/api/";

  // Get all reading lists for the current user
  Future<List<ReadingList>> getUserReadingLists(int userId) async {
    try {
      // Filter reading lists by user ID
      final result = await get(filter: {'UserId': userId});
      return result.items ?? [];
    } catch (e) {
      print('Error fetching reading lists: $e');
      return [];
    }
  }

  // Get reading list by ID
  Future<ReadingList?> getById(int id) async {
    try {
      var url = "${baseUrl}ReadingList/$id";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      var response = await http.get(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        print("Failed to get reading list: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print('Error getting reading list by ID: $e');
      return null;
    }
  }

  // Create new reading list
  Future<ReadingList> create(Map<String, dynamic> request) async {
    try {
      var url = "${baseUrl}ReadingList";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      headers['Content-Type'] = 'application/json';
      var response = await http.post(
        uri, 
        headers: headers,
        body: jsonEncode(request),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw Exception("Failed to create reading list: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print('Error creating reading list: $e');
      rethrow;
    }
  }

  // Update reading list
  Future<ReadingList> update(int id, [dynamic request]) async {
    try {
      var url = "${baseUrl}ReadingList/$id";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      headers['Content-Type'] = 'application/json';
      var response = await http.put(
        uri, 
        headers: headers,
        body: jsonEncode(request),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw Exception("Failed to update reading list: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print('Error updating reading list: $e');
      rethrow;
    }
  }

  // Delete reading list
  Future<bool> delete(int id) async {
    try {
      var url = "${baseUrl}ReadingList/$id";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      var response = await http.delete(uri, headers: headers);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error deleting reading list: $e');
      return false;
    }
  }

 
  Future<ReadingList?> addBookToList(int readingListId, int bookId, {DateTime? readAt}) async {
    try {
      var url = "${baseUrl}ReadingList/$readingListId/add-book";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      headers['Content-Type'] = 'application/json';
      
      var requestBody = {
        'bookId': bookId,
        'readAt': readAt?.toIso8601String(),
      };
      
      var response = await http.post(
        uri, 
        headers: headers,
        body: jsonEncode(requestBody),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        print("Failed to add book to list: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print('Error adding book to reading list: $e');
      return null;
    }
  }

  // Remove book from reading list
  Future<ReadingList?> removeBookFromList(int readingListId, int bookId) async {
    try {
      var url = "${baseUrl}ReadingList/$readingListId/books/$bookId";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      var response = await http.delete(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        print("Failed to remove book from list: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print('Error removing book from reading list: $e');
      return null;
    }
  }

 
  Future<ReadingList?> uploadCover(int readingListId, File coverImage) async {
    try {
      print("Uploading reading list cover. File path: ${coverImage.path}");
      var url = "${baseUrl}ReadingList/$readingListId/cover";
      print("Upload URL: $url");
      var uri = Uri.parse(url);
      var request = http.MultipartRequest('POST', uri);
      var headers = createHeaders();
      headers.remove('Content-Type');
      request.headers.addAll(headers);
      var stream = http.ByteStream(coverImage.openRead());
      var length = await coverImage.length();
      var filename = coverImage.path.split('/').last;
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
      print("Response status: ${streamedResponse.statusCode}");
      var response = await http.Response.fromStream(streamedResponse);
      print("Response body: ${response.body}");
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var data = jsonDecode(response.body);
        print("Upload successful!");
        return fromJson(data);
      } else {
        print("Upload failed with status: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception("Failed to upload reading list cover: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error in uploadCover: $e");
      rethrow;
    }
  }
} 