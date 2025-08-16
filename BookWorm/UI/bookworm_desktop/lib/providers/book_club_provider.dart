import 'package:bookworm_desktop/model/book_club.dart';
import 'package:bookworm_desktop/providers/base_provider.dart';

class BookClubProvider extends BaseProvider<BookClub> {
  BookClubProvider() : super("bookclub");

  @override
  BookClub fromJson(dynamic json) {
    return BookClub.fromJson(json);
  }
}
