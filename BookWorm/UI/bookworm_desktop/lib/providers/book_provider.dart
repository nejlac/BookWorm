import 'package:bookworm_desktop/model/book.dart';
import 'package:bookworm_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class BookProvider extends BaseProvider<Book> {
  BookProvider():super("book");

  @override
  Book fromJson(dynamic json) {
    return Book.fromJson(json);
  }

  String get baseUrl => BaseProvider.baseUrl ?? "https://localhost:7031/api/";

  Future<void> acceptBook(int id) async {
    var url = "${baseUrl}book/$id/accept";
    var headers = createHeaders();
    var response = await http.post(Uri.parse(url), headers: headers);
    if (!isValidResponse(response)) {
      throw Exception("Failed to accept book");
    }
  }

  Future<void> declineBook(int id) async {
    var url = "${baseUrl}book/$id/decline";
    var headers = createHeaders();
    var response = await http.post(Uri.parse(url), headers: headers);
    if (!isValidResponse(response)) {
      throw Exception("Failed to decline book");
    }
  }
}







