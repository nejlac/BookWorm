// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
  id: (json['id'] as num?)?.toInt() ?? 0,
  title: json['title'] as String? ?? '',
  authorId: (json['authorId'] as num?)?.toInt() ?? 0,
  authorName: json['authorName'] as String? ?? '',
  bookState: json['bookState'] as String? ?? 'Accepted',
  publicationYear: (json['publicationYear'] as num?)?.toInt() ?? 0,
  pageCount: (json['pageCount'] as num?)?.toInt() ?? 0,
  description: json['description'] as String? ?? '',
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'authorId': instance.authorId,
  'authorName': instance.authorName,
  'description': instance.description,
  'publicationYear': instance.publicationYear,
  'pageCount': instance.pageCount,
  'bookState': instance.bookState,
  'genres': instance.genres,
};
