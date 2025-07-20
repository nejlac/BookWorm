import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/statistics_provider.dart';
import '../model/statistics.dart';
import '../providers/base_provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:process_run/process_run.dart' as process;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);
  

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
  
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<List<MostReadBook>> _mostReadBooks;
  late Future<int> _booksCount;
  late Future<int> _usersCount;
  late Future<List<GenreStatistic>> _genres;
  late Future<List<AgeDistribution>> _ageDistribution;
GenreStatistic? _touchedGenre;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<StatisticsProvider>(context, listen: false);
    _mostReadBooks = provider.fetchMostReadBooks();
    _booksCount = provider.fetchBooksCount();
    _usersCount = provider.fetchUsersCount();
    _genres = provider.fetchMostReadGenres();
    _ageDistribution = provider.fetchAgeDistribution();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _generateReport,
                    icon: const Icon(Icons.insert_drive_file, color: Colors.white),
                    label: const Text('Generate report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[700],
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Most read books', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 12),
                        FutureBuilder<List<MostReadBook>>(
                          future: _mostReadBooks,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Text('No data');
                            }
                            return Column(
                              children: snapshot.data!.map((book) {
                                String? coverPath = book.coverImageUrl;
                                String? coverUrl;
                                if (coverPath != null && coverPath.isNotEmpty) {
                                  if (coverPath.startsWith('http')) {
                                    coverUrl = coverPath;
                                  } else {
                                    String base = BaseProvider.baseUrl ?? '';
                                    if (base.endsWith('/api/')) base = base.substring(0, base.length - 5);
                                    coverUrl = '$base/$coverPath';
                                  }
                                }
                                return Card(
                                  color: Colors.yellow[50],
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        coverUrl != null && coverUrl.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  coverUrl,
                                                  width: 48,
                                                  height: 64,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.book, size: 48),
                                                ),
                                              )
                                            : const Icon(Icons.book, size: 48),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                              Text(book.authorName),
                                              Row(
                                                children: [
                                                  ...List.generate(5, (i) => Icon(
                                                        i < book.averageRating.round()
                                                            ? Icons.star
                                                            : Icons.star_border,
                                                        color: Colors.amber,
                                                        size: 18,
                                                      )),
                                                  const SizedBox(width: 6),
                                                  Text('${book.ratingsCount} Ratings', style: const TextStyle(fontSize: 12)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 36),
                 Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 32),
                        
                          const SizedBox(height: 24),
                          _BeautifulStatCard(
                            label: 'Number of books',
                            future: _booksCount,
                            icon: Icons.menu_book_rounded,
                            color: Colors.yellow.shade100,
                          ),
                          const SizedBox(height: 16),
                          _BeautifulStatCard(
                            label: 'Number of users',
                            future: _usersCount,
                            icon: Icons.people_alt_rounded,
                            color: Colors.yellow.shade100,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  )

                ],
              ),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Expanded(
  flex: 2,
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              'User Age Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
          ),
          SizedBox(
            height: 240,
            child: FutureBuilder<List<AgeDistribution>>(
              future: _ageDistribution,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data'));
                }

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.brown.shade100,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final ageRange = snapshot.data![group.x.toInt()].ageRange;
                          return BarTooltipItem(
                            '$ageRange\n',
                            const TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: '${rod.toY.toInt()} users'),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                   leftTitles: AxisTitles(
                      axisNameWidget: const Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          'Number of users',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),




                      bottomTitles: AxisTitles(
                        axisNameWidget: const Padding(
                          padding: EdgeInsets.only(top: 12.0),
                          child: Text(
                            'Ages',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= snapshot.data!.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                snapshot.data![idx].ageRange,
                                style: const TextStyle(fontSize: 9),
                              ),
                            );
                          },
                          reservedSize: 36,
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    barGroups: List.generate(
                      snapshot.data!.length,
                      (i) => BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: snapshot.data![i].count.toDouble(),
                            color: Colors.brown[300],
                            width: 14,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  ),
),

                  const SizedBox(width: 32),
                            Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 170.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<List<GenreStatistic>>(
                    future: _genres,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No data');
                      }

                      final genres = snapshot.data!;

                     return Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24), 
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDE7),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Most Read Genres',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 40), 

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Expanded(
                      flex: 1,
                      child: AspectRatio(
                        aspectRatio: 1.2, 
                        child: PieChart(
                          PieChartData(
                            sections: [
                              for (final genre in genres)
                                PieChartSectionData(
                                  color: _genreColor(genre.genreName),
                                  value: genre.percentage,
                                  title: '${genre.percentage.toStringAsFixed(1)}%',
                                  radius: genre == _touchedGenre ? 70 : 60,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  showTitle: true,
                                ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 38,
                            pieTouchData: PieTouchData(
                              touchCallback: (event, response) {
                                setState(() {
                                  _touchedGenre = response?.touchedSection?.touchedSection?.value == null
                                      ? null
                                      : genres[response!.touchedSection!.touchedSectionIndex];
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

          const SizedBox(width: 32),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final genre in genres.where((g) => g.percentage > 0))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _genreColor(genre.genreName),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          genre.genreName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5D4037),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${genre.percentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8D6748),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ],
  ),
);

                    },
                  ),
                ],
              ),
            ),
          ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateReport() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(now);

    // Fetch all data for the report
    final books = await _mostReadBooks;
    final booksCount = await _booksCount;
    final usersCount = await _usersCount;
    final genres = await _genres;
    final ageDist = await _ageDistribution;

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'BookWorm Statistics Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text('Generated: $dateStr'),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFFFFDE7),
              borderRadius: pw.BorderRadius.circular(12),
              border: pw.Border.all(
                color: PdfColor.fromInt(0xFFFFD54F),
                width: 1,
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Number of books: $booksCount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                pw.Text('Number of users: $usersCount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                pw.SizedBox(height: 12),
                pw.Text('Most Read Books:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                if (books.isEmpty)
                  pw.Text('No data.'),
                if (books.isNotEmpty)
                  pw.Table.fromTextArray(
                    headers: ['Title', 'Author', 'Avg. Rating', 'Ratings', ''],
                    data: books.map((b) => [
                      b.title,
                      b.authorName,
                      b.averageRating.toStringAsFixed(2),
                      b.ratingsCount.toString(),
                      '',
                    ]).toList(),
                    cellStyle: pw.TextStyle(fontSize: 11),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    cellAlignment: pw.Alignment.centerLeft,
                    headerDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFF8E1)),
                    border: null,
                  ),
                pw.SizedBox(height: 12),
                pw.Text('Most Read Genres:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                if (genres.isEmpty)
                  pw.Text('No data.'),
                if (genres.isNotEmpty)
                  pw.Table.fromTextArray(
                    headers: ['Genre', 'Percentage'],
                    data: genres.map((g) => [g.genreName, '${g.percentage.toStringAsFixed(1)}%']).toList(),
                    cellStyle: pw.TextStyle(fontSize: 11),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    cellAlignment: pw.Alignment.centerLeft,
                    headerDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFF8E1)),
                    border: null,
                  ),
                pw.SizedBox(height: 12),
                pw.Text('User Age Distribution:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                if (ageDist.isEmpty)
                  pw.Text('No data.'),
                if (ageDist.isNotEmpty)
                  pw.Table.fromTextArray(
                    headers: ['Age Range', 'Users'],
                    data: ageDist.map((a) => [a.ageRange, a.count.toString()]).toList(),
                    cellStyle: pw.TextStyle(fontSize: 11),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    cellAlignment: pw.Alignment.centerLeft,
                    headerDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFF8E1)),
                    border: null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    try {
      final outputDir = await getApplicationDocumentsDirectory();
      final filePath = '${outputDir.path}/bookworm_statistics_report.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (Platform.isWindows) {
        await process.run('explorer', [outputDir.path]);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF: $e')),
      );
    }
  }
}

class _BookTile extends StatelessWidget {
  final MostReadBook book;
  const _BookTile({required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: book.coverImageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book.coverImageUrl,
                  width: 48,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.book, size: 48),
                ),
              )
            : const Icon(Icons.book, size: 48),
        title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.authorName),
            Row(
              children: [
                ...List.generate(5, (i) => Icon(
                      i < book.averageRating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    )),
                const SizedBox(width: 6),
                Text('${book.ratingsCount} Ratings', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BeautifulStatCard extends StatelessWidget {
  final String label;
  final Future<int> future;
  final IconData icon;
  final Color color;
  const _BeautifulStatCard({required this.label, required this.future, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: future,
      builder: (context, snapshot) {
        String value = '...';
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          value = _formatNumber(snapshot.data!);
        } else if (snapshot.connectionState == ConnectionState.done) {
          value = '-';
        }
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFD7CCC8),
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 18),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 32, color: Colors.brown[700]),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFF5D4037)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF8D6748)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ');
  }
}

Color _genreColor(String genreName) {
  // Assign specific colors for common genres to avoid collisions
  switch (genreName.toLowerCase()) {
    case 'mistery':
    case 'mystery':
      return const Color(0xFFCE93D8); // purple
    case 'adventure':
      return const Color(0xFFFFAB91); // orange
    case 'romance':
    case 'romace':
      return const Color(0xFFFFF176); // yellow
    case 'classics':
      return const Color(0xFFD7CCC8); // beige
    case 'fantasy':
      return const Color(0xFF80CBC4); // teal
    case 'science fiction':
    case 'sci-fi':
      return const Color(0xFFAED581); // green
    default:
      final colors = [
        const Color(0xFFD7CCC8),
        const Color(0xFFFFAB91),
        const Color(0xFFCE93D8),
        const Color(0xFF80CBC4),
        const Color(0xFFFFF176),
        const Color(0xFFAED581),
        Colors.blueGrey,
        Colors.pinkAccent,
        Colors.lightBlueAccent,
        Colors.deepOrangeAccent,
      ];
      return colors[genreName.hashCode.abs() % colors.length];
  }
}


