import 'package:json_annotation/json_annotation.dart';

part 'challenge.g.dart';

@JsonSerializable()
class Challenge {
  final int id;
  final int userId;
  final String userName;
  final int goal;
  final int numberOfBooksRead;
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final List<ChallengeBook> books;

  Challenge({
    this.id = 0,
    this.userId = 0,
    this.userName = '',
    this.goal = 0,
    this.numberOfBooksRead = 0,
    this.year = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.books = const [],
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return _$ChallengeFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ChallengeToJson(this);
}

@JsonSerializable()
class ChallengeBook {
  final int bookId;
  final String title;
  final DateTime completedAt;

  ChallengeBook({
    this.bookId = 0,
    this.title = '',
    required this.completedAt,
  });

  factory ChallengeBook.fromJson(Map<String, dynamic> json) {
    return _$ChallengeBookFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ChallengeBookToJson(this);
}
