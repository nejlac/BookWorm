import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'base_provider.dart';
import '../model/statistics.dart';

class StatisticsProvider with ChangeNotifier {
  StatisticsProvider();

  String get _baseUrl => BaseProvider.baseUrl ?? '';

  Future<List<MostReadBook>> fetchMostReadBooks() async {
    final url = ' _baseUrlBook/most-read'.replaceFirst(' _baseUrl', _baseUrl);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => MostReadBook.fromJson(e)).toList();
      }
      throw Exception('Failed to load most read books');
    } catch (e) {
      rethrow;
    }
  }

  Future<int> fetchBooksCount() async {
    final url = ' _baseUrlBook/count'.replaceFirst(' _baseUrl', _baseUrl);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return int.parse(response.body);
      }
      throw Exception('Failed to load books count');
    } catch (e) {
      rethrow;
    }
  }

  Future<int> fetchUsersCount() async {
    final url = ' _baseUrlUsers/count'.replaceFirst(' _baseUrl', _baseUrl);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return int.parse(response.body);
      }
      throw Exception('Failed to load users count');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GenreStatistic>> fetchMostReadGenres() async {
    final url = ' _baseUrlBook/most-read-genres'.replaceFirst(' _baseUrl', _baseUrl);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => GenreStatistic.fromJson(e)).toList();
      }
      throw Exception('Failed to load genres');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AgeDistribution>> fetchAgeDistribution() async {
    final url = ' _baseUrlUsers/age-distribution'.replaceFirst(' _baseUrl', _baseUrl);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => AgeDistribution.fromJson(e)).toList();
      }
      throw Exception('Failed to load age distribution');
    } catch (e) {
      rethrow;
    }
  }
}