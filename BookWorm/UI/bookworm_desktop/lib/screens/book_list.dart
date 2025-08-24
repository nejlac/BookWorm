import 'package:bookworm_desktop/layouts/master_screen.dart';
import 'package:bookworm_desktop/model/book.dart';
import 'package:bookworm_desktop/model/search_result.dart';
import 'package:bookworm_desktop/providers/book_provider.dart';
import 'package:bookworm_desktop/providers/genre_provider.dart';
import 'package:bookworm_desktop/screens/book_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  late BookProvider bookProvider;
  late GenreProvider genreProvider;

  TextEditingController authorController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  ScrollController _horizontalScrollController = ScrollController();

  List<Map<String, dynamic>> genres = [];
  Map<String, dynamic>? selectedGenre;
  final List<String> statuses = ['All', 'Submitted', 'Accepted', 'Declined'];
  String selectedStatus = 'All';
  SearchResult<Book>? books;

  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bookProvider = context.read<BookProvider>();
    genreProvider = context.read<GenreProvider>();
    _fetchAllBooks();
    _fetchGenres();
  }

  void _fetchAllBooks({int? page}) async {
    var filter = {
      "title": searchController.text,
      "author": authorController.text,
      "publicationYear": yearController.text,
      "genreId": (selectedGenre != null && selectedGenre!["id"] != null) ? selectedGenre!["id"] : null,
      "status": selectedStatus == 'All' ? null : selectedStatus,
      "page": (page ?? currentPage) - 1, 
      "pageSize": pageSize,
      "includeTotalCount": true,
    };
    var books = await bookProvider.get(filter: filter);
    setState(() {
      this.books = books;
      currentPage = (page ?? currentPage);
      totalPages = (books.totalCount != null && pageSize > 0)
          ? ((books.totalCount! + pageSize - 1) ~/ pageSize)
          : 1;
      if (currentPage > totalPages) currentPage = totalPages;
      if (currentPage < 1) currentPage = 1;
    });
  }

  Future<void> _fetchGenres() async {
    try {
      var loadedGenres = await genreProvider.getAllGenresForDropdown();
      setState(() {
        genres = [{'id': null, 'name': 'All'}];
        genres.addAll(loadedGenres.map((g) => {'id': g.id, 'name': g.name}));
        if (selectedGenre == null) {
          selectedGenre = genres.first;
        } else {
          selectedGenre = genres.firstWhere(
            (g) => g['id'] == selectedGenre!['id'] && g['name'] == selectedGenre!['name'],
            orElse: () => genres.first,
          );
        }
      });
    } catch (e) {
      setState(() {
        genres = [{'id': null, 'name': 'All'}];
        if (selectedGenre == null) {
          selectedGenre = genres.first;
        } else {
          selectedGenre = genres.firstWhere(
            (g) => g['id'] == selectedGenre!['id'] && g['name'] == selectedGenre!['name'],
            orElse: () => genres.first,
          );
        }
      });
      debugPrint('Failed to load genres: ' + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildAddBookButton(),
          _buildSearch(),
          Expanded(child: _buildResultView()),
          _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildAddBookButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetails(book: null, isEditMode: true),
                    ),
                  );
                  
                  
                  if (result == true) {
                    _fetchAllBooks();
                  }
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add New Book',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;
    
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 0),
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          constraints: const BoxConstraints(maxWidth: 900),
          child: isSmallScreen
              ? Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              labelText: 'Books',
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: authorController,
                            decoration: InputDecoration(
                              labelText: 'Author',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.person),
                                onPressed: () {},
                              ),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: yearController,
                            decoration: InputDecoration(
                              labelText: 'Year',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.date_range),
                                onPressed: () {},
                              ),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<Map<String, dynamic>>(
                            value: selectedGenre,
                            items: genres.map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(
                                g['name'] ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF4E342E),
                                  fontFamily: 'Literata',
                                  fontSize: 14,
                                ),
                              ),
                            )).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedGenre = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Genre',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            ),
                            style: const TextStyle(fontSize: 14, color: Color(0xFF4E342E)),
                            dropdownColor: Color(0xFFFFF8E1),
                            menuMaxHeight: 300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedStatus,
                            items: statuses.map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s,
                                style: const TextStyle(
                                  color: Color(0xFF4E342E),
                                  fontFamily: 'Literata',
                                  fontSize: 14,
                                ),
                              ),
                            )).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value ?? 'All';
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            ),
                            style: const TextStyle(fontSize: 14, color: Color(0xFF4E342E)),
                            dropdownColor: Color(0xFFFFF8E1),
                            menuMaxHeight: 300,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                              _fetchAllBooks(page: 1);
                            },
                            child: const Text('Search'),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 2,
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Books',
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
                        controller: authorController,
                        decoration: InputDecoration(
                          labelText: 'Author',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.person),
                            onPressed: () {},
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 1,
                      child: TextField(
                        controller: yearController,
                        decoration: InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.date_range),
                            onPressed: () {},
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 2,
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        value: selectedGenre,
                        items: genres.map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(
                            g['name'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFF4E342E),
                              fontFamily: 'Literata',
                              fontSize: 14,
                            ),
                          ),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGenre = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Genre',
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
                    Flexible(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: selectedStatus,
                        items: statuses.map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s,
                            style: const TextStyle(
                              color: Color(0xFF4E342E),
                              fontFamily: 'Literata',
                              fontSize: 14,
                            ),
                          ),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value ?? 'All';
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Status',
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
                          _fetchAllBooks(page: 1);
                        },
                        child: const Text('Search'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final totalCount = books?.totalCount ?? 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTableSmallScreen = constraints.maxWidth < 800;
        return Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? double.infinity : 1200,
            ),
            margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 32),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                      'Total: $totalCount book${totalCount == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontFamily: 'Literata',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF4E342E),
                      ),
                    ),
                  ),
                Expanded(
                  child: Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                                              child: Container(
                          constraints: BoxConstraints(minWidth: 1000),
                        child: DataTable(
                            showCheckboxColumn: false,
                            headingRowHeight: 48,
                            dataRowHeight: 44,
                            dividerThickness: 0.5,
                            columnSpacing: isTableSmallScreen ? 16 : 32,
                            horizontalMargin: 16,
                          columns: [
                            DataColumn(label: Container(width: 200, child: Text("Title", style: _tableHeaderStyle()))),
                            DataColumn(label: Container(width: 150, child: Text("Author", style: _tableHeaderStyle()))),
                            DataColumn(label: Container(width: 120, child: Text("Genre", style: _tableHeaderStyle()))),
                            DataColumn(label: Container(width: 80, child: Text("Pages", style: _tableHeaderStyle()))),
                            DataColumn(label: Container(width: 80, child: Text("Year", style: _tableHeaderStyle()))),
                            DataColumn(label: Container(width: 100, child: Text("State", style: _tableHeaderStyle()))),
                            DataColumn(label: Container(width: 60, child: Icon(Icons.info_outline, color: Color(0xFF8D6748)))),
                            DataColumn(label: Container(width: 60, child: Icon(Icons.edit, color: Color(0xFF8D6748)))),
                            DataColumn(label: Container(width: 60, child: Icon(Icons.delete, color: Colors.red))),
                          ],
                          dataRowColor: MaterialStateProperty.resolveWith<Color?>((states) {
                            if (states.contains(MaterialState.selected)) {
                              return const Color(0xFFFFF8E1);
                            }
                            return Colors.white;
                          }),
                          headingRowColor: MaterialStateProperty.all(const Color(0xFFF6E3B4)),
                          rows: books?.items?.map((e) => DataRow(
                            onSelectChanged: (value) {},
                            cells: [
                              DataCell(
                                Container(
                                  width: 200,
                                  child: Text(
                                    e.title,
                                    style: _tableCellStyle(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: 150,
                                  child: Text(
                                    e.authorName,
                                    style: _tableCellStyle(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: 120,
                                  child: Text(
                                    e.genres.join(', '),
                                    style: _tableCellStyle(),
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(Text(e.pageCount.toString(), style: _tableCellStyle())),
                              DataCell(Text(e.publicationYear.toString(), style: _tableCellStyle())),
                              DataCell(
                                Text(
                                  e.bookState,
                                  style: _tableCellStyle().copyWith(
                                    color: e.bookState == 'Accepted'
                                        ? Color(0xFF2E7D32)
                                        : e.bookState == 'Submitted'
                                            ? Color(0xFFC62828)
                                            : Color(0xFF4E342E),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(IconButton(
                                icon: const Icon(Icons.info_outline, color: Color(0xFF8D6748)),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookDetails(book: e, isEditMode: false,),
                                    ),
                                  );
                                  if (result == true) {
                                    _fetchAllBooks();
                                  }
                                },
                                splashRadius: 20,
                                tooltip: 'Details',
                              )),
                              DataCell(IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF8D6748)),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookDetails(book: e, isEditMode: true,),
                                    ),
                                  );
                                  if (result == true) {
                                    _fetchAllBooks();
                                  }
                                },
                                splashRadius: 20,
                                tooltip: 'Edit',
                              )),
                              DataCell(IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Book'),
                                      content: const Text('Are you sure you want to delete this book? Deleting a book will remove all its data (reviews, quotes) permanently.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            try {
                                              await bookProvider.delete(e.id);
                                              _fetchAllBooks();
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Failed to delete book: ${e.toString()}'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Delete'),
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
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls() {
    if (totalPages <= 1) return SizedBox.shrink();
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200; 
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int maxPageButtons = isSmallScreen ? 3 : 5;
          int startPage = (currentPage - (maxPageButtons ~/ 2)).clamp(1, (totalPages - maxPageButtons + 1).clamp(1, totalPages));
          int endPage = (startPage + maxPageButtons - 1).clamp(1, totalPages);
          List<int> pageNumbers = [for (int i = startPage; i <= endPage; i++) i];

          return Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 14,
                vertical: 4,
              ),
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
                    onPressed: currentPage > 1 ? () => _fetchAllBooks(page: 1) : null,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                  const SizedBox(width: 0),
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: 20, color: currentPage == 1 ? Colors.grey : Color(0xFF8D6748)),
                    tooltip: 'Previous Page',
                    onPressed: currentPage > 1 ? () => _fetchAllBooks(page: currentPage - 1) : null,
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
                        if (page != currentPage) _fetchAllBooks(page: page);
                      },
                    ),
                  )),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.chevron_right, size: 20, color: currentPage == totalPages ? Colors.grey : Color(0xFF8D6748)),
                    tooltip: 'Next Page',
                    onPressed: currentPage < totalPages ? () => _fetchAllBooks(page: currentPage + 1) : null,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                  const SizedBox(width: 0),
                  IconButton(
                    icon: Icon(Icons.last_page, size: 20, color: currentPage == totalPages ? Colors.grey : Color(0xFF8D6748)),
                    tooltip: 'Last Page',
                    onPressed: currentPage < totalPages ? () => _fetchAllBooks(page: totalPages) : null,
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
          );
        },
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

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }
}