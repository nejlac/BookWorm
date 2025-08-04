import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_statistics.dart';
import 'base_provider.dart';

class UserStatisticsProvider extends BaseProvider<dynamic> {
  UserStatisticsProvider() : super("users");

  @override
  dynamic fromJson(dynamic json) {
    return json; 
  }

  String get baseUrl => BaseProvider.baseUrl!;

  Future<List<UserGenreStatistic>> getUserMostReadGenres(int userId, {int? year}) async {
    final url = '${baseUrl}users/$userId/most-read-genres';
    final uri = Uri.parse(url).replace(queryParameters: year != null ? {'year': year.toString()} : null);
    
    try {
      final response = await http.get(uri, headers: createHeaders());
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => UserGenreStatistic.fromJson(e)).toList();
      }
      throw Exception('Failed to load user most read genres');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserRatingStatistics> getUserRatingStatistics(int userId, {int? year}) async {
    final url = '${baseUrl}users/$userId/rating-statistics';
    final uri = Uri.parse(url).replace(queryParameters: year != null ? {'year': year.toString()} : null);
    
    try {
      final response = await http.get(uri, headers: createHeaders());
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserRatingStatistics.fromJson(data);
      }
      throw Exception('Failed to load user rating statistics');
    } catch (e) {
      rethrow;
    }
  }
} 