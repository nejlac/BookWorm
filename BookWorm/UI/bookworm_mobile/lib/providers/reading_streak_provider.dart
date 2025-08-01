import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/reading_streak.dart';
import 'base_provider.dart';

class ReadingStreakProvider extends BaseProvider<ReadingStreak> {
  ReadingStreakProvider() : super("readingstreak");

  @override
  ReadingStreak fromJson(dynamic json) {
    return ReadingStreak.fromJson(json);
  }

  String get baseUrl => BaseProvider.baseUrl ?? "http://10.0.2.2:7031/api/";

  Future<ReadingStreak?> getUserStreak(int userId) async {
    final url = '${baseUrl}readingstreak/user/$userId';
    final uri = Uri.parse(url);
    
    try {
      final response = await http.get(uri, headers: createHeaders());
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ReadingStreak.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // No streak exists
      }
      throw Exception('Failed to load reading streak');
    } catch (e) {
      print('[DEBUG] Exception in getUserStreak: $e');
      rethrow;
    }
  }

  Future<ReadingStreak> markReadingActivity(int userId) async {
    final url = '${baseUrl}readingstreak/user/$userId/mark-activity';
    final uri = Uri.parse(url);
    
    try {
      final response = await http.post(uri, headers: createHeaders());
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ReadingStreak.fromJson(data);
      }
      throw Exception('Failed to mark reading activity');
    } catch (e) {
      print('[DEBUG] Exception in markReadingActivity: $e');
      rethrow;
    }
  }

  Future<ReadingStreak> createStreak(int userId) async {
    final url = '${baseUrl}readingstreak/user/$userId/create';
    final uri = Uri.parse(url);
    
    try {
      final response = await http.post(uri, headers: createHeaders());
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ReadingStreak.fromJson(data);
      }
      throw Exception('Failed to create reading streak');
    } catch (e) {
      print('[DEBUG] Exception in createStreak: $e');
      rethrow;
    }
  }
} 