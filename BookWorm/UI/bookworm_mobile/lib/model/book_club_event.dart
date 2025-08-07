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

  factory BookClubEvent.fromJson(Map<String, dynamic> json) => BookClubEvent(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        deadline: DateTime.parse(json['deadline']),
        bookId: json['bookId'],
        bookTitle: json['bookTitle'] ?? '',
        bookAuthorName: json['bookAuthorName'] ?? '',
        bookCoverImagePath: json['bookCoverImagePath'] ?? '',
        bookClubId: json['bookClubId'],
        bookClubName: json['bookClubName'] ?? '',
        creatorId: json['creatorId'],
        creatorName: json['creatorName'] ?? '',
        participantsCount: json['participantsCount'] ?? 0,
        completedParticipantsCount: json['completedParticipantsCount'] ?? 0,
        isParticipant: json['isParticipant'] ?? false,
        isCompleted: json['isCompleted'] ?? false,
        isCreator: json['isCreator'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'bookId': bookId,
        'bookTitle': bookTitle,
        'bookAuthorName': bookAuthorName,
        'bookCoverImagePath': bookCoverImagePath,
        'bookClubId': bookClubId,
        'bookClubName': bookClubName,
        'creatorId': creatorId,
        'creatorName': creatorName,
        'participantsCount': participantsCount,
        'completedParticipantsCount': completedParticipantsCount,
        'isParticipant': isParticipant,
        'isCompleted': isCompleted,
        'isCreator': isCreator,
      };
}