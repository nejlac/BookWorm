import 'package:json_annotation/json_annotation.dart';

part 'book_club_event.g.dart';

class BookClubEvent {
  final int id;
  final String title;
  final String description;
  final DateTime deadline;
  final int bookId;
  final String bookTitle;
  final String bookAuthorName;
  final String bookCoverImagePath;
  final int bookClubId;
  final String bookClubName;
  final int creatorId;
  final String creatorName;
  final int participantsCount;
  final int completedParticipantsCount;
  final bool isParticipant;
  final bool isCompleted;
  final bool isCreator;

  BookClubEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthorName,
    required this.bookCoverImagePath,
    required this.bookClubId,
    required this.bookClubName,
    required this.creatorId,
    required this.creatorName,
    required this.participantsCount,
    required this.completedParticipantsCount,
    required this.isParticipant,
    required this.isCompleted,
    required this.isCreator,
  });

  factory BookClubEvent.fromJson(Map<String, dynamic> json) => _$BookClubEventFromJson(json);

  Map<String, dynamic> toJson() => _$BookClubEventToJson(this);
}