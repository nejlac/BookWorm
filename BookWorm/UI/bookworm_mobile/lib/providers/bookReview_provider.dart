import 'package:bookworm_mobile/model/bookReview.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';


class BookReviewProvider extends BaseProvider<BookReview> {
  BookReviewProvider():super("bookReview");

 @override
  BookReview fromJson(dynamic json) {
    return BookReview.fromJson(json);
  }
}