// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_club_event.dart';

BookClubEvent _$BookClubEventFromJson(Map<String, dynamic> json) => BookClubEvent(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      bookId: json['bookId'] as int,
      bookTitle: json['bookTitle'] as String? ?? '',
      bookAuthorName: json['bookAuthorName'] as String? ?? '',
      bookCoverImagePath: json['bookCoverImagePath'] as String? ?? '',
      bookClubId: json['bookClubId'] as int,
      bookClubName: json['bookClubName'] as String? ?? '',
      creatorId: json['creatorId'] as int,
      creatorName: json['creatorName'] as String? ?? '',
      participantsCount: json['participantsCount'] as int? ?? 0,
      completedParticipantsCount: json['completedParticipantsCount'] as int? ?? 0,
      isParticipant: json['isParticipant'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isCreator: json['isCreator'] as bool? ?? false,
    );

Map<String, dynamic> _$BookClubEventToJson(BookClubEvent instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'deadline': instance.deadline.toIso8601String(),
      'bookId': instance.bookId,
      'bookTitle': instance.bookTitle,
      'bookAuthorName': instance.bookAuthorName,
      'bookCoverImagePath': instance.bookCoverImagePath,
      'bookClubId': instance.bookClubId,
      'bookClubName': instance.bookClubName,
      'creatorId': instance.creatorId,
      'creatorName': instance.creatorName,
      'participantsCount': instance.participantsCount,
      'completedParticipantsCount': instance.completedParticipantsCount,
      'isParticipant': instance.isParticipant,
      'isCompleted': instance.isCompleted,
      'isCreator': instance.isCreator,
    };