
import 'package:flutter/material.dart';
import '../model/bookChallenge.dart';
import '../providers/book_challenge_provider.dart';
import '../providers/user_provider.dart';
import '../model/user.dart';
import '../providers/base_provider.dart';
import '../providers/book_provider.dart';
import '../model/book.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert; 
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/process_run.dart' as process;
import 'package:printing/printing.dart';


class ReadingChallengeList extends StatefulWidget {
  @override
  _ReadingChallengeListState createState() => _ReadingChallengeListState();
}

class _ReadingChallengeListState extends State<ReadingChallengeList> {
  late BookChallengeProvider _provider;
  late UserProvider _userProvider;
  List<BookChallenge> _challenges = [];
  List<BookChallenge> _allChallenges = [];
  Map<int, String> _usernames = {};
  Map<int, User> _userCache = {}; 
  int _page = 1;
  int _pageSize = 10;
  int _totalCount = 0;
  String _search = '';
  String? _status;
  int? _year;
  bool _loading = true;
  int? _completedChallenges;
  List<Map<String, dynamic>> _topReaders = [];
  bool _summaryLoading = true;

  @override
  void initState() {
    super.initState();
    _provider = BookChallengeProvider();
    _userProvider = UserProvider();
    _fetchData();
    _fetchSummary();
  }



  Future<void> _fetchData() async {
    setState(() => _loading = true);
    bool? isCompletedBool;
    if (_status == 'True') isCompletedBool = true;
    else if (_status == 'False') isCompletedBool = false;
    else isCompletedBool = null;
    final Map<String, dynamic> filter = {
      'username': _search.isNotEmpty ? _search : null,
      'isCompleted': isCompletedBool,
      'year': _year,
      'page': (_page - 1).clamp(0, 99999),
      'pageSize': _pageSize,
      "includeTotalCount": true,
    };
  
    final result = await _provider.get(filter: filter);
    _challenges = result.items!;
    _totalCount = result.totalCount ?? 0;
    await _resolveUsernames();
    setState(() {
      _loading = false;
    });
  }

 
   
  

  Future<void> _resolveUsernames() async {
    final missingUserIds = _challenges.map((c) => c.userId).where((id) => !_usernames.containsKey(id)).toSet();
    for (final userId in missingUserIds) {
      try {
        final user = await _userProvider.getById(userId);
        _usernames[userId] = user.username;
      } catch (e) {
        _usernames[userId] = 'Unknown';
      }
    }
    setState(() {}); 
  }

  Future<void> _fetchSummary() async {
    setState(() { _summaryLoading = true; });
    try {
      final year = DateTime.now().year;
      String base = BaseProvider.baseUrl ?? '';
      if (base.endsWith('/api/')) base = base.substring(0, base.length - 5);
      final url = Uri.parse('$base/api/ReadingChallenge/summary?year=$year');

   
      String username = AuthProvider.username ?? '';
      String password = AuthProvider.password ?? '';
      String basicAuth = 'Basic ${convert.base64Encode(convert.utf8.encode('$username:$password'))}';

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": basicAuth,
        },
      );
   
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
      
        setState(() {
          _completedChallenges = data['completedChallenges'];
          _topReaders = List<Map<String, dynamic>>.from(data['topReaders']);
          _summaryLoading = false;
        });
      } else {
      
        setState(() { _summaryLoading = false; });
      }
    } catch (e) {
   
      setState(() { _summaryLoading = false; });
    }
  }

  Widget _buildTable() {
   
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('User', style: TextStyle(fontSize: 13))),
          DataColumn(label: Text('Goal', style: TextStyle(fontSize: 13))),
          DataColumn(label: Text('Books Read', style: TextStyle(fontSize: 13))),
          DataColumn(label: Text('Year', style: TextStyle(fontSize: 13))),
          DataColumn(label: Text('Progress', style: TextStyle(fontSize: 13))),
          DataColumn(label: Text('Status', style: TextStyle(fontSize: 13))),
          DataColumn(label: Text('View', style: TextStyle(fontSize: 13))), 
        ],
        rows: _challenges.map((challenge) {
          final progress = challenge.goal > 0
              ? ((challenge.numberOfBooksRead / challenge.goal) * 100).round()
              : 0;
          final username = _usernames[challenge.userId] ?? 'Unknown';
          return DataRow(cells: [
            DataCell(Text(username, style: TextStyle(fontSize: 13))),
            DataCell(Text('${challenge.goal}', style: TextStyle(fontSize: 13))),
            DataCell(Text('${challenge.numberOfBooksRead}', style: TextStyle(fontSize: 13))),
            DataCell(Text('${challenge.year}', style: TextStyle(fontSize: 13))),
            DataCell(Text('$progress%', style: TextStyle(fontSize: 13))),
            DataCell(Row(
              children: [
                Icon(
                  challenge.isCompleted ? Icons.check_circle : Icons.circle,
                  color: challenge.isCompleted ? Colors.green : Colors.red,
                  size: 14,
                ),
                SizedBox(width: 2),
                Text(challenge.isCompleted ? 'Completed' : 'In progress', style: TextStyle(fontSize: 13)),
              ],
            )),
            DataCell(
              IconButton(
                icon: Icon(Icons.remove_red_eye, color: Colors.brown),
                tooltip: 'View books read',
                onPressed: () async {
                  await _showBooksReadDialog(context, challenge);
                },
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildPagination() {
    if (_totalCount == 0) return SizedBox.shrink();
    int pageCount = (_totalCount / _pageSize).ceil();
    if (pageCount == 0) pageCount = 1;

    int startPage = (_page - 5).clamp(1, (pageCount - 9).clamp(1, pageCount));
    int endPage = (startPage + 9).clamp(1, pageCount);

    List<int> pageNumbers = [for (int i = startPage; i <= endPage; i++) i];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, size: 18),
          onPressed: _page > 1 ? () { setState(() { _page--; _fetchData(); }); } : null,
        ),
        ...pageNumbers.map((i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: SizedBox(
            height: 28,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _page == i ? Colors.amber : null,
                minimumSize: Size(28, 28),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              ),
              onPressed: () { setState(() { _page = i; _fetchData(); }); },
              child: Text('$i', style: TextStyle(fontSize: 13)),
            ),
          ),
        )),
        IconButton(
          icon: Icon(Icons.chevron_right, size: 18),
          onPressed: _page < pageCount ? () { setState(() { _page++; _fetchData(); }); } : null,
        ),
      ],
    );
  }

 Widget _buildFilters() {
  TextEditingController _searchController = TextEditingController(text: _search);
  TextEditingController _yearController = TextEditingController(text: _year?.toString() ?? '');
  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallScreen = screenWidth < 1200;
  
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: isSmallScreen
        ? Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      isDense: true,
                      decoration: InputDecoration(
                        labelText: 'Is Completed',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: null, child: Text('All')),
                        DropdownMenuItem(value: 'True', child: Text('Completed')),
                        DropdownMenuItem(value: 'False', child: Text('In progress')),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _status = v;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _yearController,
                      decoration: InputDecoration(
                        labelText: 'Year',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _search = _searchController.text;
                        _year = int.tryParse(_yearController.text);
                        _page = 1; // Reset to first page when searching
                      });
                      _fetchData();
                    },
                    child: Text('Search'),
                  ),
                ],
              ),
            ],
          )
        : Row(
      children: [
        SizedBox(
          width: 140,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Username',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            style: TextStyle(fontSize: 13),
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: 140,
          child: DropdownButtonFormField<String>(
            value: _status,
            isDense: true,
            decoration: InputDecoration(
              labelText: 'Is Completed',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: 'True', child: Text('Completed')),
              DropdownMenuItem(value: 'False', child: Text('In progress')),
            ],
            onChanged: (v) {
              setState(() {
                _status = v;
              });
            },
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: TextField(
            controller: _yearController,
            decoration: InputDecoration(
              labelText: 'Year',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 13),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _search = _searchController.text;
              _year = int.tryParse(_yearController.text);
                    _page = 1; // Reset to first page when searching
            });
            _fetchData();
          },
          child: Text('Search'),
        ),
      ],
    ),
  );
}

  Future<void> _showBooksReadDialog(BuildContext context, BookChallenge challenge) async {
  final bookProvider = BookProvider();
  final booksRead = challenge.books;
  List<Book> bookDetails = [];
  for (final b in booksRead) {
    try {
      final book = await bookProvider.getById(b.bookId);
      bookDetails.add(book);
    } catch (e) {
      print("Error fetching book details for ID ${b.bookId}: $e");
    }
  }
  int progress = challenge.goal > 0 ? ((challenge.numberOfBooksRead / challenge.goal) * 100).round() : 0;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Books read in ${challenge.year}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
             
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8),
                  Text('$progress%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
                  SizedBox(height: 4),
                  Center(
                    child: SizedBox(
                      width: 220,
                      child: LinearProgressIndicator(
                        value: (progress.clamp(0, 100)) / 100.0,
                        minHeight: 16,
                        backgroundColor: Colors.brown.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('Challenge progress', textAlign: TextAlign.center),
                ],
              ),
              Expanded(
                child: bookDetails.isEmpty
                    ? Text('No books read.')
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: bookDetails.length,
                        itemBuilder: (context, index) {
                          final book = bookDetails[index];
                          String? coverPath = book.coverImagePath;
                          String coverUrl;
                          if (coverPath != null && coverPath.isNotEmpty) {
                            String base = BaseProvider.baseUrl ?? '';
                            if (base.endsWith('/api/')) {
                              base = base.substring(0, base.length - 5);
                            }
                            coverUrl = '$base/$coverPath';
                          } else {
                            coverUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(book.title)}&background=random';
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    coverUrl,
                                    width: 48,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 48,
                                      height: 72,
                                      color: Colors.grey[200],
                                      child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(book.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      SizedBox(height: 4),
                                      Text(book.authorName, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}
void _generateReport() async {
  final pdf = pw.Document();
  final now = DateTime.now();
  final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(now);

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Text(
            'Reading Challenge Report',
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
              pw.Text(
                'Completed challenges (${DateTime.now().year}):',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
              ),
              pw.Text(
                _completedChallenges?.toString() ?? '-',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF8D6748),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Top readers of the year:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
              ),
              if (_topReaders.isEmpty)
                pw.Text('No top readers.'),
              if (_topReaders.isNotEmpty)
                pw.Column(
                  children: _topReaders.map((reader) {
                    return pw.Row(
                      children: [
                        pw.Text(
                          reader['username'] ?? '',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Text(
                          'Books read: ${reader['numberOfBooksRead'] ?? 0}',
                          style: pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        pw.SizedBox(height: 24),
        pw.Text(
          'Current Table Data',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
        ),
        pw.SizedBox(height: 8),
        pw.Table.fromTextArray(
          headers: ['User', 'Goal', 'Books Read', 'Year', 'Progress', 'Status'],
          data: _challenges.map((challenge) {
            final progress = challenge.goal > 0
                ? ((challenge.numberOfBooksRead / challenge.goal) * 100).round()
                : 0;
            return [
              challenge.userName,
              challenge.goal.toString(),
              challenge.numberOfBooksRead.toString(),
              challenge.year.toString(),
              '$progress%',
              challenge.isCompleted ? 'Completed' : 'In progress',
            ];
          }).toList(),
          cellStyle: pw.TextStyle(fontSize: 11),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          cellAlignment: pw.Alignment.centerLeft,
          headerDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFF8E1)),
          border: null,
        ),
      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
    name: 'Reading Challenge Report',
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('PDF report generated successfully!'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

  Widget _buildSummaryCards(String completedChallenges, List<Widget> topReaderWidgets) {
    return Column(
      children: [
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Colors.yellow[50],
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber[800], size: 32),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Completed challenges', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        Text('(${DateTime.now().year})', style: TextStyle(fontSize: 13, color: Colors.brown)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(completedChallenges, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.brown[700], letterSpacing: 2)),
              ],
            ),
          ),
        ),
        SizedBox(height: 32),
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Colors.yellow[50],
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber[800], size: 28),
                    SizedBox(width: 10),
                    Text('Top readers of the year', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                SizedBox(height: 16),
                ...topReaderWidgets,
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200; // Threshold for responsive layout
    
    if (_summaryLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
   
    String completedChallenges = _completedChallenges?.toString() ?? '...';
    List<Widget> topReaderWidgets = [];
    for (final reader in _topReaders) {
      String imageUrl;
      final photoUrl = reader['photoUrl'] as String?;
      if (photoUrl != null && photoUrl.isNotEmpty) {
        if (photoUrl.startsWith('http')) {
          imageUrl = photoUrl;
        } else {
          String base = BaseProvider.baseUrl ?? '';
          if (base.endsWith('/api/')) base = base.substring(0, base.length - 5);
          imageUrl = '$base/$photoUrl';
        }
      } else {
        imageUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(reader['username'] ?? '')}&background=random';
      }
      topReaderWidgets.add(_buildTopReader(reader['username'] ?? '', reader['numberOfBooksRead'] ?? 0, imageUrl));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: _summaryLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24, left: 8, right: 8, bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _generateReport,
                        child: Text('+ Generate report'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                      ),
                    ],
                  ),
                ),
                if (_totalCount > 0)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFF6E3B4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF8D6748), width: 1),
                      ),
                      child: Text(
                        'Total: $_totalCount challenge${_totalCount == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontFamily: 'Literata',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF4E342E),
                        ),
                      ),
                    ),
                  ),
                
                Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 700),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: _buildFilters(),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 1200),
                      child: isSmallScreen
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Small screen: Give table more height
                                Expanded(
                                  flex: 3, // Give table more space
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: _buildTable(),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: _buildPagination(),
                                  ),
                                ),
                                SizedBox(height: 24),
                                // Summary cards for small screen - take less space
                                Expanded(
                                  flex: 1, // Take less space
                                  child: SingleChildScrollView(
                                    child: _buildSummaryCards(completedChallenges, topReaderWidgets),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: _buildTable(),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: _buildPagination(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                                // Summary cards for large screen
                          SizedBox(
                            width: 340,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                                    child: _buildSummaryCards(completedChallenges, topReaderWidgets),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTopReader(String name, int books, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(imageUrl), radius: 20),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Read $books books', style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        ],
      ),
    );
  }
}
