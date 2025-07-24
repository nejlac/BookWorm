import 'package:json_annotation/json_annotation.dart';

part 'book.g.dart';
@JsonSerializable()
class Book {
  final int id;
  final String title;
  final int authorId;
  final String authorName;
  final String description;
   final int publicationYear;
    final int pageCount;
  final String bookState;
  final List<String> genres;
  final String? coverImagePath;

  Book({
    this.id = 0,
    this.title = '',
    this.authorId = 0,
    this.authorName = '',
    this.bookState = 'Accepted',
    this.publicationYear = 0,
    this.pageCount = 0,
    this.description = '',
    this.genres = const [],
    this.coverImagePath,
  });
  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
}