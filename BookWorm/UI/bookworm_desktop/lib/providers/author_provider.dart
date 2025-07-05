import 'package:bookworm_desktop/model/author.dart';
import 'package:bookworm_desktop/providers/base_provider.dart';

class AuthorProvider extends BaseProvider<Author> {
  AuthorProvider():super("author");

  @override
  Author fromJson(dynamic json) {
    return Author.fromJson(json);
  }
  
  Future<List<Author>> getAllAuthors() async {
    try {
      final result = await get();
      return result.items ?? [];
    } catch (e) {
      print('Error fetching authors: $e');
      return [];
    }
  }
} 