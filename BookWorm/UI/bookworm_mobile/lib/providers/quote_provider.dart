import 'package:bookworm_mobile/model/quote.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';

class QuoteProvider extends BaseProvider<Quote> {
  QuoteProvider():super("quote");

 @override
  Quote fromJson(dynamic json) {
    return Quote.fromJson(json);
  }

}