// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingList _$ReadingListFromJson(Map<String, dynamic> json) => ReadingList(
  id: (json['id'] as num?)?.toInt() ?? 0,
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  userName: json['userName'] as String? ?? '',
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  isPublic: json['isPublic'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  coverImagePath: json['coverImagePath'] as String?,
  books: (json['books'] as List<dynamic>?)
      ?.map((e) => ReadingListBook.fromJson(e as Map<String, dynamic>))
      .toList() ?? const [],
);

Map<String, dynamic> _$ReadingListToJson(ReadingList instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'name': instance.name,
  'description': instance.description,
  'isPublic': instance.isPublic,
  'createdAt': instance.createdAt.toIso8601String(),
  'coverImagePath': instance.coverImagePath,
  'books': instance.books.map((e) => e.toJson()).toList(),
}; 