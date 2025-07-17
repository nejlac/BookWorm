import 'package:json_annotation/json_annotation.dart';

part 'bookChallenge.g.dart';
@JsonSerializable()
class BookChallenge {
  final int id;
  final int userId;
  final String userName;
  final int goal;
  final int numberOfBooksRead;
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final List<BookChallengeBook> books;

  BookChallenge({
    required this.id,
    required this.userId,
    required this.userName,
    required this.goal,
    required this.numberOfBooksRead,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
    required this.isCompleted,
    required this.books,
  });

  factory BookChallenge.fromJson(Map<String, dynamic> json) => _$BookChallengeFromJson(json);
}

class BookChallengeBook {
  final int bookId;
  final String title;
  final DateTime completedAt;

  BookChallengeBook({
    required this.bookId,
    required this.title,
    required this.completedAt,
  });

  factory BookChallengeBook.fromJson(Map<String, dynamic> json) => _$BookChallengeBookFromJson(json);
}