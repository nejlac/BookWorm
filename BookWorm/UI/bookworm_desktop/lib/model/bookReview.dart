import 'package:json_annotation/json_annotation.dart';

part 'bookReview.g.dart';
@JsonSerializable()
class BookReview {
  final int id;
  final int userId;
  final String userName;
  final int bookId;
  final String bookTitle;
  final String? review;
  final int rating;
  final bool isChecked;
  final DateTime createdAt;


  BookReview({
    this.id = 0,
    this.userId = 0,
    this.userName = '',
    this.bookId = 0,
    this.bookTitle = '',
    this.review = '',
    this.rating = 0,
    this.isChecked = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  factory BookReview.fromJson(Map<String, dynamic> json) => _$BookReviewFromJson(json);
  
  }
