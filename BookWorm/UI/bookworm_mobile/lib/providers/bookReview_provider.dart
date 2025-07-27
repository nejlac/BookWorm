import 'package:bookworm_mobile/model/bookReview.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class BookReviewProvider extends BaseProvider<BookReview> {
  BookReviewProvider():super("bookReview");

 @override
  BookReview fromJson(dynamic json) {
    return BookReview.fromJson(json);
  }

  Future<void> checkReview(int id) async {
    var url = "${BaseProvider.baseUrl}bookReview/$id/check";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.put(uri, headers: headers);
    if (!isValidResponse(response)) {
      throw Exception("Failed to check review");
    }
  }
}