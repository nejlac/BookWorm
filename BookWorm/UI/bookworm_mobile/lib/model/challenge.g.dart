// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Challenge _$ChallengeFromJson(Map<String, dynamic> json) => Challenge(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      userName: json['userName'] as String? ?? '',
      goal: json['goal'] as int? ?? 0,
      numberOfBooksRead: json['numberOfBooksRead'] as int? ?? 0,
      year: json['year'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      books: (json['books'] as List<dynamic>?)
              ?.map((e) => ChallengeBook.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ChallengeToJson(Challenge instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'goal': instance.goal,
      'numberOfBooksRead': instance.numberOfBooksRead,
      'year': instance.year,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'books': instance.books,
    };

ChallengeBook _$ChallengeBookFromJson(Map<String, dynamic> json) => ChallengeBook(
      bookId: json['bookId'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      completedAt: DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$ChallengeBookToJson(ChallengeBook instance) => <String, dynamic>{
      'bookId': instance.bookId,
      'title': instance.title,
      'completedAt': instance.completedAt.toIso8601String(),
    }; 