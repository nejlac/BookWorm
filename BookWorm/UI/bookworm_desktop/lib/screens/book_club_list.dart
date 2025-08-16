import 'package:bookworm_desktop/layouts/master_screen.dart';
import 'package:bookworm_desktop/model/book_club.dart';
import 'package:bookworm_desktop/model/search_result.dart';
import 'package:bookworm_desktop/providers/book_club_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookClubList extends StatefulWidget {
  const BookClubList({super.key});

  @override
  State<BookClubList> createState() => _BookClubListState();
}

class _BookClubListState extends State<BookClubList> {
  late BookClubProvider bookClubProvider;
  
  TextEditingController searchController = TextEditingController();
  TextEditingController creatorController = TextEditingController();

  String sortMode = 'members_desc'; 
  
  SearchResult<BookClub>? bookClubs;

  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bookClubProvider = context.read<BookClubProvider>();
    _fetchAllBookClubs();
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
                                             : SingleChildScrollView(
                           child: SingleChildScrollView(
                             scrollDirection: Axis.horizontal,
                             child: DataTable(
                               headingTextStyle: TextStyle(
                                 fontWeight: FontWeight.bold,
                                 color: Color(0xFF5D4037),
                               ),
                               columns: [
                                 DataColumn(label: Text('ID')),
                                 DataColumn(label: Text('Name')),
                                 DataColumn(label: Text('Description')),
                                 DataColumn(label: Text('Creator ID')),
                                 DataColumn(label: Text('Members')),
                                 DataColumn(label: Text('Events')),
                                 DataColumn(label: Text('Created')),
                                 DataColumn(label: Text('Delete')),
                               ],
                            rows: bookClubs!.items!.map((bookClub) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(bookClub.id.toString())),
                                  DataCell(
                                    Text(
                                      bookClub.name,
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      width: 200,
                                      child: Text(
                                        bookClub.description,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(bookClub.creatorId.toString())),
                                  DataCell(Text(bookClub.membersCount.toString())),
                                  DataCell(Text(bookClub.eventsCount.toString())),
                                  DataCell(Text(
                                    '${bookClub.createdAt.day}/${bookClub.createdAt.month}/${bookClub.createdAt.year}',
                                  )),
                                                                     DataCell(
                                     IconButton(
                                       icon: Icon(Icons.delete, color: Colors.red),
                                       onPressed: () => _confirmDeleteBookClub(bookClub),
                                       tooltip: 'Delete Book Club',
                                     ),
                                   ),
                                ],
                              );
                            }).toList(),
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
}
