import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../model/user_statistics.dart';
import '../utils/genre_colors.dart';

class GenrePieChart extends StatelessWidget {
  final List<UserGenreStatistic> genres;
  final double size;

  const GenrePieChart({
    Key? key,
    required this.genres,
    this.size = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (genres.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE0C9A6),
        ),
        child: const Center(
          child: Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: Color(0xFF8D6748),
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: size * 0.25,
          sections: genres.map((genre) {
            return PieChartSectionData(
              color: GenreColors.getGenreColor(genre.genreName),
              value: genre.percentage,
              title: genre.percentage >= 10 ? '${genre.percentage.toStringAsFixed(1)}%' : '',
              radius: size * 0.35,
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black26,
                  ),
                ],
              ),
            );
          }).toList(),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
} 