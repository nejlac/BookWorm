// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookReview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookReview _$BookReviewFromJson(Map<String, dynamic> json) => BookReview(
  id: (json['id'] as num?)?.toInt() ?? 0,
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  userName: json['userName'] as String? ?? '',
  bookId: (json['bookId'] as num?)?.toInt() ?? 0,
  bookTitle: json['bookTitle'] as String? ?? '',
  review: json['review'] as String?,
  rating: (json['rating'] as num?)?.toInt() ?? 0,
  isChecked: json['isChecked'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
);


