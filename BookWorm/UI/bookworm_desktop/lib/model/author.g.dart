// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Author _$AuthorFromJson(Map<String, dynamic> json) => Author(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  biography: json['biography'] as String? ?? '',
  dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
  dateOfDeath: json['dateOfDeath'] == null
      ? null
      : DateTime.parse(json['dateOfDeath'] as String),
  countryId: (json['countryId'] as num?)?.toInt() ?? 0,
  countryName: json['countryName'] as String? ?? '',
  photoUrl: json['photoUrl'] as String?,
  authorState: json['authorState'] as String? ?? '',
);

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'biography': instance.biography,
  'dateOfBirth': instance.dateOfBirth.toIso8601String(),
  'dateOfDeath': instance.dateOfDeath?.toIso8601String(),
  'countryId': instance.countryId,
  'countryName': instance.countryName,
  'photoUrl': instance.photoUrl,
  'authorState': instance.authorState,
};
