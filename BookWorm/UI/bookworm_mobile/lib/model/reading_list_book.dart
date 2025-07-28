import 'package:json_annotation/json_annotation.dart';

part 'reading_list_book.g.dart';

@JsonSerializable()
class ReadingListBook {
  final int bookId;
  final String title;
  final DateTime addedAt;
  final String? coverImagePath;

  ReadingListBook({
    this.bookId = 0,
    this.title = '',
    required this.addedAt,
    this.coverImagePath,
  });

  factory ReadingListBook.fromJson(Map<String, dynamic> json) {
    return _$ReadingListBookFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ReadingListBookToJson(this);
} 