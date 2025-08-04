import 'package:bookworm_mobile/model/challenge.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:bookworm_mobile/providers/auth_provider.dart';
import 'package:bookworm_mobile/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChallengeProvider extends BaseProvider<Challenge> {
  ChallengeProvider() : super("readingchallenge");

  @override
  Challenge fromJson(dynamic json) {
    return Challenge.fromJson(json);
  }

  String get baseUrl => BaseProvider.baseUrl!;


  Future<void> addBookToChallenge(int userId, int year, int bookId, DateTime completedAt) async {
    try {
      final url = Uri.parse('${baseUrl}Readingchallenge/add-book');
      
      final response = await http.post(
        url,
        headers: createHeaders(),
        body: jsonEncode({
          'userId': userId,
          'year': year,
          'bookId': bookId,
          'completedAt': completedAt.toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add book to challenge: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeBookFromChallenge(int userId, int year, int bookId) async {
    try {
      final url = Uri.parse('${baseUrl}Readingchallenge/remove-book');
      
      final response = await http.delete(
        url,
        headers: createHeaders(),
        body: jsonEncode({
          'userId': userId,
          'year': year,
          'bookId': bookId,
          'completedAt': DateTime.now().toIso8601String(), 
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove book from challenge: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Challenge?> getUserChallenge(int userId, int year) async {
    try {
      final username = AuthProvider.username;
      if (username == null) return null;
      
      final filter = {
        'username': username,
        'year': year,
        'pageSize': 1,
      };

      final result = await get(filter: filter);
      return result.items?.isNotEmpty == true ? result.items!.first : null;
    } catch (e) {
      print('Error getting user challenge: $e');
      return null;
    }
  }

  Future<List<Challenge>> getUserChallenges(int userId) async {
    try {
      final username = AuthProvider.username;
      if (username == null) return [];
      
      final filter = {
        'username': username,
      };

      final result = await get(filter: filter);
      return result.items ?? [];
    } catch (e) {
      print('Error getting user challenges: $e');
      return [];
    }
  }

  Future<Challenge> createChallenge(int userId, int goal, int year, {List<int> bookIds = const []}) async {
    try {
      final request = {
        'userId': userId,
        'goal': goal,
        'year': year,
        'bookIds': bookIds,
        'isCompleted': false,
      };

      return await insert(request);
    } catch (e) {
      print('Error creating challenge: $e');
      rethrow;
    }
  }

  Future<Challenge?> updateChallenge(int challengeId, int goal, int year, {List<int> bookIds = const []}) async {
    try {
      final username = AuthProvider.username;
      if (username == null) throw Exception('User not authenticated');
      
      final userProvider = UserProvider();
      final userResult = await userProvider.get(filter: {'username': username, 'pageSize': 1});
      final user = userResult.items?.isNotEmpty == true ? userResult.items!.first : null;
      if (user == null) throw Exception('User not found');
      
      final request = {
        'userId': user.id,
        'goal': goal,
        'year': year,
        'bookIds': bookIds,
        'isCompleted': false,
      };

      return await update(challengeId, request);
    } catch (e) {
      print('Error updating challenge: $e');
      rethrow;
    }
  }

  Future<bool> deleteChallenge(int challengeId) async {
    try {
      await delete(challengeId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
