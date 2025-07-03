import 'dart:developer' as developer;

import 'package:bookworm_desktop/model/book.dart';
import 'package:bookworm_desktop/model/search_result.dart';
import 'package:bookworm_desktop/providers/book_provider.dart';

class LoggedBookProvider extends BookProvider {
  @override
  Future<SearchResult<Book>> get({dynamic filter}) async {
    developer.log('Starting book fetch request', name: 'LoggedBookProvider');
    
    try {
      final startTime = DateTime.now();
      final result = await super.get(filter: filter);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      developer.log(
        'Book fetch completed successfully in ${duration.inMilliseconds}ms',
        name: 'LoggedBookProvider'
      );
      
      
      return result;
    } catch (e) {
      developer.log(
        'Book fetch failed with error: $e',
        name: 'LoggedBookProvider',
        error: e
      );
      rethrow;
    }
  }
}