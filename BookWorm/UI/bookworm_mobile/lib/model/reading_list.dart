import 'package:json_annotation/json_annotation.dart';
import 'package:bookworm_mobile/model/reading_list_book.dart';

part 'reading_list.g.dart';

@JsonSerializable()
class ReadingList {
  final int id;
  final int userId;
  final String userName;
  final String name;
  final String description;
  final bool isPublic;
  final DateTime createdAt;
  final String? coverImagePath;
  final List<ReadingListBook> books;

  ReadingList({
    this.id = 0,
    this.userId = 0,
    this.userName = '',
    this.name = '',
    this.description = '',
    this.isPublic = true,
    required this.createdAt,
    this.coverImagePath,
    this.books = const [],
  });

  factory ReadingList.fromJson(Map<String, dynamic> json) {
    return _$ReadingListFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ReadingListToJson(this);

  int get bookCount => books.length;

  String? get firstBookCoverUrl {
   
    if (coverImagePath != null && coverImagePath!.isNotEmpty) {
      return coverImagePath;
    }
  
    if (books.isNotEmpty) {
      return books.first.coverImagePath;
    }
    return null;
  }
} 