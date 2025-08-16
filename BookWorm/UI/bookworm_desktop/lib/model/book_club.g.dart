// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_club.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookClub _$BookClubFromJson(Map<String, dynamic> json) => BookClub(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      creatorId: json['creatorId'] as int? ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      memberIds: (json['memberIds'] as List<dynamic>?)?.cast<int>() ?? const [],
      eventIds: (json['eventIds'] as List<dynamic>?)?.cast<int>() ?? const [],
      membersCount: json['membersCount'] as int? ?? 0,
      eventsCount: json['eventsCount'] as int? ?? 0,
      isMember: json['isMember'] as bool? ?? false,
      isCreator: json['isCreator'] as bool? ?? false,
    );

Map<String, dynamic> _$BookClubToJson(BookClub instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'creatorId': instance.creatorId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'memberIds': instance.memberIds,
      'eventIds': instance.eventIds,
      'membersCount': instance.membersCount,
      'eventsCount': instance.eventsCount,
      'isMember': instance.isMember,
      'isCreator': instance.isCreator,
    };
