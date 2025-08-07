import 'dart:convert';

import 'package:bookworm_mobile/model/book_club_event.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class BookClubEventProvider extends BaseProvider<BookClubEvent> {
  BookClubEventProvider() : super("bookclubevent");

  @override
  BookClubEvent fromJson(dynamic json) {
    return BookClubEvent.fromJson(json);
  }

  String get baseUrl => BaseProvider.baseUrl!;

  Future<List<BookClubEvent>> getAllBookClubEvents() async {
    try {
      final result = await get(filter: {'RetrieveAll': true});
      return result.items ?? [];
    } catch (e) {
      print('Error fetching book club events: $e');
      return [];
    }
  }

  Future<BookClubEvent> getById(int id) async {
    var url = "${BaseProvider.baseUrl}bookclubevent/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to get book club event: \\${response.statusCode} - \\${response.body}");
    }
  }

  Future<bool> participateInEvent(int eventId) async {
    try {
      var url = "${BaseProvider.baseUrl}bookclubevent/participate";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      headers['Content-Type'] = 'application/json';
      
      var requestBody = jsonEncode({
        'bookClubEventId': eventId,
      });
      
      var response = await http.post(uri, headers: headers, body: requestBody);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to participate in event');
      }
    } catch (e) {
      print('Error participating in event: $e');
      rethrow;
    }
  }

  Future<bool> leaveEvent(int eventId) async {
    try {
      var url = "${BaseProvider.baseUrl}bookclubevent/$eventId/leave";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      
      var response = await http.post(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to leave event');
      }
    } catch (e) {
      print('Error leaving event: $e');
      rethrow;
    }
  }

  Future<bool> markEventAsCompleted(int eventId) async {
    try {
      var url = "${BaseProvider.baseUrl}bookclubevent/$eventId/complete";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      
      var response = await http.post(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to mark event as completed');
      }
    } catch (e) {
      print('Error marking event as completed: $e');
      rethrow;
    }
  }

  Future<BookClubEvent> createEvent(String title, String description, DateTime deadline, int bookId, int bookClubId) async {
    try {
      var url = "${BaseProvider.baseUrl}bookclubevent";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      headers['Content-Type'] = 'application/json';
      
      var requestBody = jsonEncode({
        'title': title,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'bookId': bookId,
        'bookClubId': bookClubId,
      });
      
      var response = await http.post(uri, headers: headers, body: requestBody);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create event');
      }
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  Future<BookClubEvent> updateEvent(int eventId, String title, String description, DateTime deadline, int bookId) async {
    try {
      var url = "${BaseProvider.baseUrl}bookclubevent/$eventId";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      headers['Content-Type'] = 'application/json';
      
      var requestBody = jsonEncode({
        'title': title,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'bookId': bookId,
      });
      
      var response = await http.put(uri, headers: headers, body: requestBody);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update event');
      }
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  Future<bool> deleteEvent(int eventId) async {
    try {
      var url = "${BaseProvider.baseUrl}bookclubevent/$eventId";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      
      var response = await http.delete(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete event');
      }
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }
}