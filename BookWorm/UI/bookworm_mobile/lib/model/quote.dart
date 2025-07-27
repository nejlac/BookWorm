import 'package:json_annotation/json_annotation.dart';

part 'quote.g.dart';
@JsonSerializable()
class Quote {
  final int id;
  final int? userId;
  final int bookId;
  final String quoteText;


  Quote({
    this.id = 0,
    this.userId,
    this.bookId = 0,
    this.quoteText = '',
  });
  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
  
  }