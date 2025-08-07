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

  factory BookClub.fromJson(Map<String, dynamic> json) => BookClub(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        creatorId: json['creatorId'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        memberIds: List<int>.from(json['memberIds'] ?? []),
        eventIds: List<int>.from(json['eventIds'] ?? []),
        membersCount: json['membersCount'] ?? 0,
        eventsCount: json['eventsCount'] ?? 0,
        isMember: json['isMember'] ?? false,
        isCreator: json['isCreator'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'creatorId': creatorId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'memberIds': memberIds,
        'eventIds': eventIds,
        'membersCount': membersCount,
        'eventsCount': eventsCount,
        'isMember': isMember,
        'isCreator': isCreator,
      };
}