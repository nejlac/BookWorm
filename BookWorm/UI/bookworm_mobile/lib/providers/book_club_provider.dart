import 'dart:convert';

import 'package:bookworm_mobile/model/book_club.dart';
import 'package:bookworm_mobile/model/book_club_event.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class BookClubProvider extends BaseProvider<BookClub> {
  BookClubProvider() : super("bookclub");

  @override
  BookClub fromJson(dynamic json) {
    return BookClub.fromJson(json);
  }

  String get baseUrl => BaseProvider.baseUrl!;

  Future<List<BookClub>> getAllBookClubs() async {
    try {
      final result = await get(filter: {'RetrieveAll': true});
      return result.items ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<BookClub> getById(int id) async {
    var url = "${BaseProvider.baseUrl}bookclub/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to get book club: \\${response.statusCode} - \\${response.body}");
    }
  }

  Future<List<BookClubEvent>> getBookClubEvents(int bookClubId) async {
    try {
      var url = "${BaseProvider.baseUrl}bookclubevent/bookclub/$bookClubId";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      var response = await http.get(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var data = jsonDecode(response.body);
        return (data as List).map((json) => BookClubEvent.fromJson(json)).toList();
      } else {
        throw Exception("Failed to get book club events: \\${response.statusCode} - \\${response.body}");
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getBookClubMembers(int bookClubId) async {
    try {
      var url = "${BaseProvider.baseUrl}bookclub/$bookClubId/members";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      var response = await http.get(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var data = jsonDecode(response.body);
        return (data as List).cast<Map<String, dynamic>>();
      } else {
        throw Exception("Failed to get book club members: \\${response.statusCode} - \\${response.body}");
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool> joinBookClub(int bookClubId) async {
    try {
      var url = "${BaseProvider.baseUrl}bookclub/join";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      headers['Content-Type'] = 'application/json';
      
      var requestBody = jsonEncode({
        'bookClubId': bookClubId,
      });
      
      var response = await http.post(uri, headers: headers, body: requestBody);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to join book club');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> leaveBookClub(int bookClubId) async {
    try {
      var url = "${BaseProvider.baseUrl}bookclub/$bookClubId/leave";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      
      var response = await http.post(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to leave book club');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<BookClub> createBookClub(String name, String description) async {
    try {
      var url = "${BaseProvider.baseUrl}bookclub";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      headers['Content-Type'] = 'application/json';
      
      var requestBody = jsonEncode({
        'name': name,
        'description': description,
      });
      
      var response = await http.post(uri, headers: headers, body: requestBody);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create book club');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<BookClub> updateBookClub(int id, String name, String description) async {
    try {
      var url = "${BaseProvider.baseUrl}bookclub/$id";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      headers['Content-Type'] = 'application/json';
      
      var requestBody = jsonEncode({
        'name': name,
        'description': description,
      });
      
      var response = await http.put(uri, headers: headers, body: requestBody);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update book club');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteBookClub(int id) async {
    try {
      var url = "${BaseProvider.baseUrl}bookclub/$id";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      
      var response = await http.delete(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete book club');
      }
    } catch (e) {
      rethrow;
    }
  }
}