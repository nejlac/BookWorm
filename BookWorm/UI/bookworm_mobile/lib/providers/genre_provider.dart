import 'package:bookworm_mobile/model/genre.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GenreProvider extends BaseProvider<Genre> {
  GenreProvider() : super("Genre");
  
  @override
  Genre fromJson(dynamic json) {
    return Genre.fromJson(json);
  }
  String get baseUrl => BaseProvider.baseUrl!;
  Future<List<Genre>> getAllGenres() async {
    final url = "${baseUrl}Genre";
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: createHeaders());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map && data.containsKey('items')) {
        final items = data['items'];
        if (items is List) {
          return List<Genre>.from(items.map((e) => Genre.fromJson(e)));
        } else {
          return [];
        }
      }

      if (data is List) {
        return List<Genre>.from(data.map((e) => Genre.fromJson(e)));
      } else {
        throw Exception("Unexpected genre response format");
      }
    } else {
      throw Exception("Failed to load genres: "+response.statusCode.toString());
    }
  }
}