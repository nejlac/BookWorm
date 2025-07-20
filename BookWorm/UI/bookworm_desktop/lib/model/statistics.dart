class MostReadBook {
  final int bookId;
  final String title;
  final String authorName;
  final String coverImageUrl;
  final double averageRating;
  final int ratingsCount;

  MostReadBook({
    required this.bookId,
    required this.title,
    required this.authorName,
    required this.coverImageUrl,
    required this.averageRating,
    required this.ratingsCount,
  });

  factory MostReadBook.fromJson(Map<String, dynamic> json) => MostReadBook(
        bookId: json['bookId'],
        title: json['title'],
        authorName: json['authorName'],
        coverImageUrl: json['coverImageUrl'] ?? '',
        averageRating: (json['averageRating'] as num).toDouble(),
        ratingsCount: json['ratingsCount'],
      );
}

class GenreStatistic {
  final String genreName;
  final double percentage;

  GenreStatistic({
    required this.genreName,
    required this.percentage,
  });

  factory GenreStatistic.fromJson(Map<String, dynamic> json) => GenreStatistic(
        genreName: json['genreName'],
        percentage: (json['percentage'] as num).toDouble(),
      );
}

class AgeDistribution {
  final String ageRange;
  final int count;

  AgeDistribution({
    required this.ageRange,
    required this.count,
  });

  factory AgeDistribution.fromJson(Map<String, dynamic> json) => AgeDistribution(
        ageRange: json['ageRange'],
        count: json['count'],
      );
}