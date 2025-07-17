part of 'bookChallenge.dart';

BookChallenge _$BookChallengeFromJson(Map<String, dynamic> json) {
  return BookChallenge(
    id: json['id'],
    userId: json['userId'],
    userName: json['userName'] ?? '',
    goal: json['goal'],
    numberOfBooksRead: json['numberOfBooksRead'],
    year: json['year'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    isCompleted: json['isCompleted'],
    books: (json['books'] as List<dynamic>?)?.map((e) => BookChallengeBook.fromJson(e)).toList() ?? [],
  );
}

BookChallengeBook _$BookChallengeBookFromJson(Map<String, dynamic> json) {
  return BookChallengeBook(
    bookId: json['bookId'],
    title: json['title'] ?? '',
    completedAt: DateTime.parse(json['completedAt']),
  );
} 