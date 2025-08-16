import 'package:json_annotation/json_annotation.dart';

part 'book_club.g.dart';

@JsonSerializable()
class BookClub {
  final int id;
  final String name;
  final String description;
  final int creatorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<int> memberIds;
  final List<int> eventIds;
  final int membersCount;
  final int eventsCount;
  final bool isMember;
  final bool isCreator;

  BookClub({
    this.id = 0,
    this.name = '',
    this.description = '',
    this.creatorId = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.memberIds = const [],
    this.eventIds = const [],
    this.membersCount = 0,
    this.eventsCount = 0,
    this.isMember = false,
    this.isCreator = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory BookClub.fromJson(Map<String, dynamic> json) => _$BookClubFromJson(json);
  Map<String, dynamic> toJson() => _$BookClubToJson(this);
}
