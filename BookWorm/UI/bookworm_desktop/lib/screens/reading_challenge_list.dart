
import 'package:flutter/material.dart';
import '../model/bookChallenge.dart';
import '../providers/book_challenge_provider.dart';
import '../providers/user_provider.dart';
import '../model/user.dart';
import '../providers/base_provider.dart';
import '../providers/book_provider.dart';
import '../model/book.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert; // for base64Encode
import '../providers/auth_provider.dart';

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
  Map<int, User> _userCache = {}; // userId -> User
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
          DataColumn(label: Text('View', style: TextStyle(fontSize: 13))), // New column
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

    // Show a window of 10 pages around the current page
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
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
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


  @override
  Widget build(BuildContext context) {
    // Show loading until summary is loaded
    if (_summaryLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Use _completedChallenges and _topReaders for summary widgets:
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
                        onPressed: () {/* Generate report logic */},
                        child: Text('+ Generate report'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                      ),
                    ],
                  ),
                ),
                // Centered filter above the table
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Main Table
                          Expanded(
                            child: Column(
                              children: [
                                // Table
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: _buildTable(),
                                  ),
                                ),
                                // Centered pagination below the table
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
                          SizedBox(
                            width: 340,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
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
                                  // Top readers card
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
                              ),
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
