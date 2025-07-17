import 'package:bookworm_desktop/model/bookChallenge.dart';
import 'package:bookworm_desktop/providers/base_provider.dart';

class BookChallengeProvider extends BaseProvider<BookChallenge> {
  BookChallengeProvider() : super("ReadingChallenge");

  @override
  BookChallenge fromJson(dynamic json) {
    return BookChallenge.fromJson(json);
  }
} 