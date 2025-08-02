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

  Future<List<ReadingList>> getUserReadingLists(int userId) async {
    try {
      
      final result = await get(filter: {'UserId': userId});
      return result.items ?? [];
    } catch (e) {
      return [];
    }
  }

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
        return null;
      }
    } catch (e) {
      return null;
    }
  }

 
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
      rethrow;
    }
  }

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
      rethrow;
    }
  }


  Future<bool> delete(int id) async {
    try {
      var url = "${baseUrl}ReadingList/$id";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      var response = await http.delete(uri, headers: headers);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
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
        return null;
      }
    } catch (e) {
      return null;
    }
  }

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
        return null;
      }
    } catch (e) {
      return null;
    }
  }

 
  Future<ReadingList?> uploadCover(int readingListId, File coverImage) async {
    try {
      var url = "${baseUrl}ReadingList/$readingListId/cover";
   
      var uri = Uri.parse(url);
      var request = http.MultipartRequest('POST', uri);
      var headers = createHeaders();
      headers.remove('Content-Type');
      request.headers.addAll(headers);
      var stream = http.ByteStream(coverImage.openRead());
      var length = await coverImage.length();
      var filename = coverImage.path.split('/').last;
      var multipartFile = http.MultipartFile(
        'coverImage',
        stream,
        length,
        filename: filename,
      );
      request.files.add(multipartFile);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw Exception("Failed to upload reading list cover: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }
} 