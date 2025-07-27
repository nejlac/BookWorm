// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quote _$QuoteFromJson(Map<String, dynamic> json) => Quote(
  id: (json['id'] as num?)?.toInt() ?? 0,
  userId: (json['userId'] as num?)?.toInt(),
  bookId: (json['bookId'] as num?)?.toInt() ?? 0,
  quoteText: json['quoteText'] as String? ?? '',
);