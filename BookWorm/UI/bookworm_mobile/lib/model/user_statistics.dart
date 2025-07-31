class UserGenreStatistic {
  final String genreName;
  final double percentage;

  UserGenreStatistic({
    required this.genreName,
    required this.percentage,
  });

  factory UserGenreStatistic.fromJson(Map<String, dynamic> json) => UserGenreStatistic(
        genreName: json['genreName'],
        percentage: (json['percentage'] as num).toDouble(),
      );
}

class UserRatingStatistics {
  final double averageRating;
  final int totalReviews;
  final Map<double, int> ratingDistribution;

  UserRatingStatistics({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory UserRatingStatistics.fromJson(Map<String, dynamic> json) {
    Map<double, int> distribution = {};
    if (json['ratingDistribution'] != null) {
      final Map<String, dynamic> distMap = json['ratingDistribution'];
      distMap.forEach((key, value) {
        distribution[double.parse(key)] = value as int;
      });
    }

    return UserRatingStatistics(
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'],
      ratingDistribution: distribution,
    );
  }
} 