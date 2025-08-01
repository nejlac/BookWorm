class ReadingStreak {
  final int id;
  final int userId;
  final String userName;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastReadingDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActiveToday;
  final int daysSinceLastReading;

  ReadingStreak({
    required this.id,
    required this.userId,
    required this.userName,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastReadingDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isActiveToday,
    required this.daysSinceLastReading,
  });

  factory ReadingStreak.fromJson(Map<String, dynamic> json) => ReadingStreak(
        id: json['id'],
        userId: json['userId'],
        userName: json['userName'] ?? '',
        currentStreak: json['currentStreak'],
        longestStreak: json['longestStreak'],
        lastReadingDate: DateTime.parse(json['lastReadingDate']),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        isActiveToday: json['isActiveToday'],
        daysSinceLastReading: json['daysSinceLastReading'],
      );
} 