import 'package:json_annotation/json_annotation.dart';

part 'book_club.g.dart';


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
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.createdAt,
    required this.updatedAt,
    required this.memberIds,
    required this.eventIds,
    this.membersCount = 0,
    this.eventsCount = 0,
    this.isMember = false,
    this.isCreator = false,
  });
factory BookClub.fromJson(Map<String, dynamic> json) => _$BookClubFromJson(json);
  Map<String, dynamic> toJson() => _$BookClubToJson(this);
}