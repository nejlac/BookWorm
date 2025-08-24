import 'package:bookworm_desktop/layouts/master_screen.dart';
import 'package:bookworm_desktop/model/book_club.dart';
import 'package:bookworm_desktop/model/search_result.dart';
import 'package:bookworm_desktop/model/user.dart';
import 'package:bookworm_desktop/providers/book_club_provider.dart';
import 'package:bookworm_desktop/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookClubList extends StatefulWidget {
  const BookClubList({super.key});

  @override
  State<BookClubList> createState() => _BookClubListState();
}

class _BookClubListState extends State<BookClubList> {
  late BookClubProvider bookClubProvider;
  late UserProvider userProvider;
  
  TextEditingController searchController = TextEditingController();
  TextEditingController creatorController = TextEditingController();
  ScrollController _horizontalScrollController = ScrollController();
  
  Map<int, String> userUsernames = {}; // Cache za username-ove

  String sortMode = 'members_desc'; 
  
  SearchResult<BookClub>? bookClubs;

  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bookClubProvider = context.read<BookClubProvider>();
    userProvider = UserProvider();
    _fetchAllBookClubs();
  }

  Future<String> _getUsername(int userId) async {
    if (userUsernames.containsKey(userId)) {
      return userUsernames[userId]!;
    }
    
    try {
      final filter = {
        'id': userId.toString(),
        'pageSize': 1,
      };
      final result = await userProvider.get(filter: filter);
      if (result.items != null && result.items!.isNotEmpty) {
        final username = result.items!.first.username;
        userUsernames[userId] = username;
        return username;
      }
    } catch (e) {
      // Ako ne možemo da dohvatimo username, vraćamo ID
    }
    return userId.toString();
  }

  void _fetchAllBookClubs({int? page}) async {
    var filter = {
      "name": searchController.text,
      "creatorId": creatorController.text.isNotEmpty ? int.tryParse(creatorController.text) : null,
      "pageSize": pageSize,
      "page": (page ?? currentPage) - 1,
      "includeTotalCount": true,
    };
    
    var bookClubs = await bookClubProvider.get(filter: filter);
    setState(() {
      this.bookClubs = bookClubs;
      currentPage = (page ?? currentPage);
      totalPages = (bookClubs.totalCount != null && pageSize > 0)
          ? ((bookClubs.totalCount! + pageSize - 1) ~/ pageSize)
          : 1;
      if (currentPage > totalPages) currentPage = totalPages;
      if (currentPage < 1) currentPage = 1;
    });
  }

  void _toggleSortMode() {
    setState(() {
      if (bookClubs != null && bookClubs!.items != null) {
        if (sortMode == 'members_desc') {
          sortMode = 'members_asc';
          bookClubs!.items!.sort((a, b) => a.membersCount.compareTo(b.membersCount));
        } else {
          sortMode = 'members_desc';
          bookClubs!.items!.sort((a, b) => b.membersCount.compareTo(a.membersCount));
        }
      }
    });
  }

  IconData _getSortIcon() {
    return sortMode == 'members_desc' ? Icons.arrow_downward : Icons.arrow_upward;
  }

  String _getSortTooltip() {
    return sortMode == 'members_desc' 
        ? 'Sort by number of members (lowest first)' 
        : 'Sort by number of members (highest first)';
  }

  String _getSortText() {
    return sortMode == 'members_desc' ? 'Members ↓' : 'Members ↑';
  }

  void _confirmDeleteBookClub(BookClub bookClub) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Book Club'),
          content: Text('Are you sure you want to delete "${bookClub.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBookClub(bookClub.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteBookClub(int bookClubId) async {
    try {
      await bookClubProvider.delete(bookClubId);
      _fetchAllBookClubs();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Book club deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete book club: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book Clubs',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
                     ),
           SizedBox(height: 32),

           Container(
             padding: EdgeInsets.all(20),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(12),
               boxShadow: [
                 BoxShadow(
                   color: Colors.black.withOpacity(0.05),
                   blurRadius: 10,
                   offset: Offset(0, 2),
                 ),
               ],
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   'Filters',
                   style: TextStyle(
                     fontSize: 18,
                     fontWeight: FontWeight.w600,
                     color: Color(0xFF5D4037),
                   ),
                 ),
                                   SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  labelText: 'Search by name',
                                  hintText: 'Enter book club name...',
                                  prefixIcon: Icon(Icons.search, color: Color(0xFF8D6748)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Color(0xFF8D6748)),
                                  ),
                                ),
                                onChanged: (value) => _fetchAllBookClubs(),
                              ),
                            ),
                            SizedBox(width: 16),

                            Expanded(
                              child: TextField(
                                controller: creatorController,
                                decoration: InputDecoration(
                                  labelText: 'Creator ID',
                                  hintText: 'Enter creator ID...',
                                  prefixIcon: Icon(Icons.person, color: Color(0xFF8D6748)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Color(0xFF8D6748)),
                                  ),
                                ),
                                onChanged: (value) => _fetchAllBookClubs(),
                              ),
                            ),
                            SizedBox(width: 16),

                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF8D6748),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Color(0xFF8D6748),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: _toggleSortMode,
                                    icon: Icon(
                                      _getSortIcon(),
                                      color: Colors.white,
                                    ),
                                    tooltip: _getSortTooltip(),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Text(
                                      _getSortText(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                labelText: 'Search by name',
                                hintText: 'Enter book club name...',
                                prefixIcon: Icon(Icons.search, color: Color(0xFF8D6748)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Color(0xFF8D6748)),
                                ),
                              ),
                              onChanged: (value) => _fetchAllBookClubs(),
                            ),
                            SizedBox(height: 16),

                            TextField(
                              controller: creatorController,
                              decoration: InputDecoration(
                                labelText: 'Creator ID',
                                hintText: 'Enter creator ID...',
                                prefixIcon: Icon(Icons.person, color: Color(0xFF8D6748)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Color(0xFF8D6748)),
                                ),
                              ),
                              onChanged: (value) => _fetchAllBookClubs(),
                            ),
                            SizedBox(height: 16),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF8D6748),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Color(0xFF8D6748),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: _toggleSortMode,
                                      icon: Icon(
                                        _getSortIcon(),
                                        color: Colors.white,
                                      ),
                                      tooltip: _getSortTooltip(),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Text(
                                        _getSortText(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
               ],
             ),
           ),
           SizedBox(height: 24),

          if (bookClubs != null)
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                '${bookClubs!.totalCount ?? 0} book clubs found',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: bookClubs == null
                  ? Center(child: CircularProgressIndicator(color: Color(0xFF8D6748)))
                  : bookClubs!.items!.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.group_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No book clubs found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                                                                                                : Container(
                            height: 600, // Ograničavam visinu tabele
                            child: Scrollbar(
                              controller: _horizontalScrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              child: SingleChildScrollView(
                                controller: _horizontalScrollController,
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  constraints: BoxConstraints(minWidth: 1000),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: DataTable(
                                  columnSpacing: 16,
                                  horizontalMargin: 12,
                                  headingTextStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5D4037),
                                  ),
                               columns: [
                                 DataColumn(label: Container(width: 80, child: Text('ID'))),
                                 DataColumn(label: Container(width: 150, child: Text('Name'))),
                                 DataColumn(label: Container(width: 200, child: Text('Description'))),
                                 DataColumn(label: Container(width: 100, child: Text('Creator'))),
                                 DataColumn(label: Container(width: 100, child: Text('Members'))),
                                 DataColumn(label: Container(width: 100, child: Text('Events'))),
                                 DataColumn(label: Container(width: 120, child: Text('Created'))),
                                 DataColumn(label: Container(width: 80, child: Text('Delete'))),
                               ],
                            rows: bookClubs!.items!.map((bookClub) {
                              return DataRow(
                                cells: [
                                  DataCell(Container(width: 80, child: Text(bookClub.id.toString()))),
                                  DataCell(Container(width: 150, child: Text(
                                    bookClub.name,
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ))),
                                  DataCell(Container(width: 200, child: Text(
                                    bookClub.description,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ))),
                                  DataCell(Container(width: 100, child: FutureBuilder<String>(
                                    future: _getUsername(bookClub.creatorId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Text('Loading...', style: TextStyle(fontSize: 12));
                                      }
                                      return Text(
                                        snapshot.data ?? bookClub.creatorId.toString(),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
                                  ))),
                                  DataCell(Container(width: 100, child: Text(bookClub.membersCount.toString()))),
                                  DataCell(Container(width: 100, child: Text(bookClub.eventsCount.toString()))),
                                  DataCell(Container(width: 120, child: Text(
                                    '${bookClub.createdAt.day}/${bookClub.createdAt.month}/${bookClub.createdAt.year}',
                                  ))),
                                  DataCell(Container(width: 80, child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmDeleteBookClub(bookClub),
                                    tooltip: 'Delete Book Club',
                                  ))),
                                ],
                              );
                                                        }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
          ),

                   ),         
          if (bookClubs != null && totalPages > 1)
            Container(
              margin: EdgeInsets.only(top: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: currentPage > 1 ? () => _fetchAllBookClubs(page: currentPage - 1) : null,
                    icon: Icon(Icons.chevron_left),
                    color: currentPage > 1 ? Color(0xFF8D6748) : Colors.grey,
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Page $currentPage of $totalPages',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  SizedBox(width: 16),
                  IconButton(
                    onPressed: currentPage < totalPages ? () => _fetchAllBookClubs(page: currentPage + 1) : null,
                    icon: Icon(Icons.chevron_right),
                    color: currentPage < totalPages ? Color(0xFF8D6748) : Colors.grey,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }
}