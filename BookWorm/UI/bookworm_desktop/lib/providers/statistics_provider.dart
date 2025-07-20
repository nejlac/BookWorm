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
    print('[DEBUG] Fetching MostReadBooks: $url');
    try {
      final response = await http.get(Uri.parse(url));
      print('[DEBUG] Status: ${response.statusCode}');
      print('[DEBUG] Body: ${response.body}');
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        print('[DEBUG] Decoded MostReadBooks: $data');
        return data.map((e) => MostReadBook.fromJson(e)).toList();
      }
      throw Exception('Failed to load most read books');
    } catch (e) {
      print('[DEBUG] Exception in fetchMostReadBooks: $e');
      rethrow;
    }
  }

  Future<int> fetchBooksCount() async {
    final url = ' _baseUrlBook/count'.replaceFirst(' _baseUrl', _baseUrl);
    print('[DEBUG] Fetching BooksCount: $url');
    try {
      final response = await http.get(Uri.parse(url));
      print('[DEBUG] Status: ${response.statusCode}');
      print('[DEBUG] Body: ${response.body}');
      if (response.statusCode == 200) {
        return int.parse(response.body);
      }
      throw Exception('Failed to load books count');
    } catch (e) {
      print('[DEBUG] Exception in fetchBooksCount: $e');
      rethrow;
    }
  }

  Future<int> fetchUsersCount() async {
    final url = ' _baseUrlUsers/count'.replaceFirst(' _baseUrl', _baseUrl);
    print('[DEBUG] Fetching UsersCount: $url');
    try {
      final response = await http.get(Uri.parse(url));
      print('[DEBUG] Status: ${response.statusCode}');
      print('[DEBUG] Body: ${response.body}');
      if (response.statusCode == 200) {
        return int.parse(response.body);
      }
      throw Exception('Failed to load users count');
    } catch (e) {
      print('[DEBUG] Exception in fetchUsersCount: $e');
      rethrow;
    }
  }

  Future<List<GenreStatistic>> fetchMostReadGenres() async {
    final url = ' _baseUrlBook/most-read-genres'.replaceFirst(' _baseUrl', _baseUrl);
    print('[DEBUG] Fetching MostReadGenres: $url');
    try {
      final response = await http.get(Uri.parse(url));
      print('[DEBUG] Status: ${response.statusCode}');
      print('[DEBUG] Body: ${response.body}');
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        print('[DEBUG] Decoded MostReadGenres: $data');
        return data.map((e) => GenreStatistic.fromJson(e)).toList();
      }
      throw Exception('Failed to load genres');
    } catch (e) {
      print('[DEBUG] Exception in fetchMostReadGenres: $e');
      rethrow;
    }
  }

  Future<List<AgeDistribution>> fetchAgeDistribution() async {
    final url = ' _baseUrlUsers/age-distribution'.replaceFirst(' _baseUrl', _baseUrl);
    print('[DEBUG] Fetching AgeDistribution: $url');
    try {
      final response = await http.get(Uri.parse(url));
      print('[DEBUG] Status: ${response.statusCode}');
      print('[DEBUG] Body: ${response.body}');
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        print('[DEBUG] Decoded AgeDistribution: $data');
        return data.map((e) => AgeDistribution.fromJson(e)).toList();
      }
      throw Exception('Failed to load age distribution');
    } catch (e) {
      print('[DEBUG] Exception in fetchAgeDistribution: $e');
      rethrow;
    }
  }
}