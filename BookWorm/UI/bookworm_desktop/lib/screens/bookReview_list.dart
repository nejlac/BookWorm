
import 'package:bookworm_desktop/model/bookReview.dart';
import 'package:bookworm_desktop/providers/base_provider.dart';
import 'package:bookworm_desktop/model/search_result.dart';
import 'package:bookworm_desktop/providers/bookReview_provider.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';


class BookReviewList extends StatefulWidget {
  const BookReviewList({super.key});

  @override
  State<BookReviewList> createState() => _BookReviewListState();
}

class _BookReviewListState extends State<BookReviewList> {
  late BookReviewProvider bookReviewProvider;
  

  TextEditingController bookTitle = TextEditingController();
  TextEditingController username = TextEditingController();
 
  SearchResult<BookReview>? bookReviews;

  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;
  String? selectedStatus;
  final List<Map<String, dynamic>> statusOptions = [
    {'value': null, 'label': 'All'},
    {'value': 'True', 'label': 'Checked'},
    {'value': 'False', 'label': 'Not checked'},
  ];
  bool ratingSortAsc = false;
  

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bookReviewProvider = context.read<BookReviewProvider>();
    _fetchAllBookReviews();
  
  }

  Future<void> _fetchAllBookReviews({int? page}) async {
    try {
      final filter = {
        "includeTotalCount": true,
        "bookTitle": bookTitle.text.isNotEmpty ? bookTitle.text : null,
        "username":  username.text.isNotEmpty ? username.text : null,
        "page": (page ?? currentPage) -1,
        "pageSize": pageSize,
        "isChecked": selectedStatus,
      };
      bookReviews = await bookReviewProvider.get(filter: filter);
      setState(() {
        this.bookReviews = bookReviews;
  currentPage = (page ?? currentPage);
  if (bookReviews?.totalCount != null && pageSize > 0) {
    totalPages = ((bookReviews!.totalCount! + pageSize - 1) ~/ pageSize);
    if (currentPage > totalPages) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;
  }
      });
    } catch (e) {
      debugPrint("Error fetching authors: $e");
    }
  }
  String truncateReview(String? review) {
    if (review == null) return 'No review';
    final words = review.split(' ');
    if (words.length <= 5) return review;
    return words.take(5).join(' ') + '...';
  }


  @override
  void initState() {
    super.initState();
   
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
           
            _buildSearch(),
            _buildResultView(),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
   
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 0),
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          constraints: const BoxConstraints(maxWidth: 900),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: TextField(
                  controller: username,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.book),
                      onPressed: () {},
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 2,
                child: TextField(
                  controller: bookTitle,
                  decoration: InputDecoration(
                    labelText: 'Book title',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.book),
                      onPressed: () {},
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
             
              Flexible(
                flex: 2,
                child: DropdownButtonFormField<String?>(
                  value: selectedStatus,
                  items: statusOptions.map((s) => DropdownMenuItem<String?>(
                    value: s['value'],
                    child: Text(s['label'],
                      style: TextStyle(
                        color: s['value'] == 'True'
                            ? Color(0xFF388E3C)
                            : s['value'] == 'False'
                                ? Color(0xFFC62828)
                                : Color(0xFF4E342E),
                                   
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Is checked',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF4E342E)),
                  dropdownColor: Color(0xFFFFF8E1),
                  menuMaxHeight: 300,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D6748),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontFamily: 'Literata',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    _fetchAllBookReviews(page: 1);
                  },
                  child: const Text('Search'),
                ),
              ),
              const SizedBox(width: 18),
              SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF8D6748)),
                    foregroundColor: Color(0xFF8D6748),
                    backgroundColor: Color(0xFFFFF8E1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      ratingSortAsc = !ratingSortAsc;
                    });
                  },
                  icon: Icon(
                    ratingSortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 18,
                  ),
                  label: Text(
                    'Sort by Rating',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Literata'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildResultView() {
    final totalCount = bookReviews?.totalCount ?? 0;
    List<BookReview>? sortedItems = bookReviews?.items;
    if (sortedItems != null) {
      sortedItems = List<BookReview>.from(sortedItems);
      sortedItems.sort((a, b) => ratingSortAsc ? a.rating.compareTo(b.rating) : b.rating.compareTo(a.rating));
    }
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200), 
        margin: const EdgeInsets.only(top: 0),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (totalCount > 0)
                Container(
                  margin: const EdgeInsets.only(left: 12, bottom: 8, top: 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFF6E3B4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF8D6748), width: 1),
                  ),
                  child: Text(
                    'Total: $totalCount review${totalCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF4E342E),
                    ),
                  ),
                ),
              DataTable(
              showCheckboxColumn: false,
              headingRowHeight: 48,
              dataRowHeight: 44,
              dividerThickness: 0.5,
              columnSpacing: 32,
              horizontalMargin: 16,
              columns: [
                DataColumn(label: Text("Review id", style: _tableHeaderStyle())),
                DataColumn(label: Text("Book title", style: _tableHeaderStyle())),
                DataColumn(label: Text("Username", style: _tableHeaderStyle())),
                DataColumn(label: Text("Rating", style: _tableHeaderStyle())),
                DataColumn(label: Text("Review", style: _tableHeaderStyle())),
                DataColumn(label: Text("Status", style: _tableHeaderStyle())),
                DataColumn(label: Icon(Icons.info_outline, color: Color(0xFF8D6748))),
                DataColumn(label: Icon(Icons.delete, color: Colors.red)),
              ],
              dataRowColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.selected)) {
                  return const Color(0xFFFFF8E1);
                }
                return Colors.white;
              }),
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF6E3B4)),
              rows: sortedItems?.map((e) => DataRow(
                onSelectChanged: (value) {},
                cells: [
                  DataCell(Text(e.id.toString(), style: _tableCellStyle())),
                  DataCell(Text(e.bookTitle, style: _tableCellStyle())),
                   
                  DataCell(Text(e.userName, style: _tableCellStyle())),
                  DataCell(Row(
                    children: List.generate(
                      e.rating,
                      (index) => Icon(Icons.star, color: Color(0xFFFFC107), size: 20),
                    ),
                  )),
                  DataCell(
                    Text(
                      truncateReview(e.review),
                      style: _tableCellStyle().copyWith(
                        color: e.review != null ? Color(0xFF4E342E) : Color(0xFFBCAAA4),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: e.isChecked ? Color(0xFFE8F5E9) : Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: e.isChecked ? Color(0xFF388E3C) : Color(0xFFC62828),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        e.isChecked ? 'Checked' : 'Not checked',
                        style: TextStyle(
                          color: e.isChecked ? Color(0xFF388E3C) : Color(0xFFC62828),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Literata',
                        ),
                      ),
                    ),
                  ),
  DataCell(IconButton(
    icon: const Icon(Icons.info_outline, color: Color(0xFF8D6748)),
    onPressed: () async {
    
      if (!e.isChecked) {
        try {
          await bookReviewProvider.checkReview(e.id);
        } catch (err) {
        }
      }
      await showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 400,
            padding: EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Color(0xFF8D6748),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Full Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: Text(
                      e.review ?? 'No review',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4E342E),
                        fontFamily: 'Literata',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8D6748),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await _fetchAllBookReviews(page: currentPage);
    },
    splashRadius: 20,
    tooltip: 'Details',
  )),
                 
                  DataCell(IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Review'),
                          content: const Text('Are you sure you want to delete this review?'),
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  try {
                                    await bookReviewProvider.delete(e.id);
                                    Navigator.pop(context);
                                    _fetchAllBookReviews();
                                  } catch (error) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.error, color: Colors.white),
                                            SizedBox(width: 12),
                                            Text("Failed to delete review: "+error.toString()),
                                          ],
                                        ),
                                        backgroundColor: Color(0xFFF44336),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }
                              },
                              child: const Text('Delete'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                    splashRadius: 20,
                    tooltip: 'Delete',
                  )),
                ],
              )).toList() ?? [],
            ),
            ],
          ),
        ),
      ),
    );
  }
  TextStyle _tableHeaderStyle() {
    return const TextStyle(
      fontFamily: 'Literata',
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Color(0xFF5D4037),
      letterSpacing: 1.1,
    );
  }

  TextStyle _tableCellStyle() {
    return const TextStyle(
      fontFamily: 'Literata',
      fontSize: 15,
      color: Color(0xFF4E342E),
    );
  }

   Widget _buildPaginationControls() {
    if (totalPages <= 1) return SizedBox.shrink();
    int maxPageButtons = 5;
    int startPage = (currentPage - (maxPageButtons ~/ 2)).clamp(1, (totalPages - maxPageButtons + 1).clamp(1, totalPages));
    int endPage = (startPage + maxPageButtons - 1).clamp(1, totalPages);
    List<int> pageNumbers = [for (int i = startPage; i <= endPage; i++) i];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(color: Color(0xFF8D6748), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.first_page, size: 20, color: currentPage == 1 ? Colors.grey : Color(0xFF8D6748)),
                tooltip: 'First Page',
                onPressed: currentPage > 1 ? () => _fetchAllBookReviews(page: 1) : null,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              const SizedBox(width: 0),
              IconButton(
                icon: Icon(Icons.chevron_left, size: 20, color: currentPage == 1 ? Colors.grey : Color(0xFF8D6748)),
                tooltip: 'Previous Page',
                onPressed: currentPage > 1 ? () => _fetchAllBookReviews(page: currentPage - 1) : null,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              const SizedBox(width: 4),
              ...pageNumbers.map((page) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: ChoiceChip(
                  label: Text('$page', style: TextStyle(
                    fontFamily: 'Literata',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: page == currentPage ? Colors.white : Color(0xFF8D6748),
                  )),
                  selected: page == currentPage,
                  selectedColor: Color(0xFF8D6748),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Color(0xFF8D6748), width: 1),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 0),
                  onSelected: (selected) {
                    if (page != currentPage) _fetchAllBookReviews(page: page);
                  },
                ),
              )),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 20, color: currentPage == totalPages ? Colors.grey : Color(0xFF8D6748)),
                tooltip: 'Next Page',
                onPressed: currentPage < totalPages ? () => _fetchAllBookReviews(page: currentPage + 1) : null,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              const SizedBox(width: 0),
              IconButton(
                icon: Icon(Icons.last_page, size: 20, color: currentPage == totalPages ? Colors.grey : Color(0xFF8D6748)),
                tooltip: 'Last Page',
                onPressed: currentPage < totalPages ? () => _fetchAllBookReviews(page: totalPages) : null,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              const SizedBox(width: 10),
              Text(
                'Page $currentPage of $totalPages',
                style: TextStyle(
                  fontFamily: 'Literata',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF8D6748),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
 