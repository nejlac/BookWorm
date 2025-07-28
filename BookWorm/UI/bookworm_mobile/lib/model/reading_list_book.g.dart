// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_list_book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingListBook _$ReadingListBookFromJson(Map<String, dynamic> json) => ReadingListBook(
  bookId: (json['bookId'] as num?)?.toInt() ?? 0,
  title: json['title'] as String? ?? '',
  addedAt: DateTime.parse(json['addedAt'] as String),
  coverImagePath: json['coverImagePath'] as String?,
);

Map<String, dynamic> _$ReadingListBookToJson(ReadingListBook instance) => <String, dynamic>{
  'bookId': instance.bookId,
  'title': instance.title,
  'addedAt': instance.addedAt.toIso8601String(),
  'coverImagePath': instance.coverImagePath,
}; 