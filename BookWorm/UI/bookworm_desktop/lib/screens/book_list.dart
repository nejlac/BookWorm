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

  void _fetchGenres() async {
    try {
      var loadedGenres = await genreProvider.getAllGenres();
      debugPrint('Loaded genres: ' + loadedGenres.toString());
      setState(() {
        genres = [{'id': null, 'name': 'All'}];
        genres.addAll(loadedGenres.map((g) => {'id': g.id, 'name': g.name}));
        if (selectedGenre == null) selectedGenre = genres.first;
      });
    } catch (e) {
      setState(() {
        genres = [{'id': null, 'name': 'All'}];
        if (selectedGenre == null) selectedGenre = genres.first;
      });
      debugPrint('Failed to load genres: ' + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Book List",
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            _buildAddBookButton(),
            _buildSearch(),
            _buildResultView(),
            _buildPaginationControls(),
          ],
        ),
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
                  
                  // Refresh the book list if book was added successfully
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
                  backgroundColor: Color(0xFF4CAF50), // Green color for add
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
                        color: Color(0xFF4E342E), // dark brown for visibility
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
                    _fetchAllBooks(page: 1); // reset to first page on search
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1000), 
            child: DataTable(
              showCheckboxColumn: false,
              headingRowHeight: 48,
              dataRowHeight: 44,
              dividerThickness: 0.5,
              columnSpacing: 32,
              horizontalMargin: 16,
              columns: [
                DataColumn(label: Text("Title", style: _tableHeaderStyle())),
                DataColumn(label: Text("Author", style: _tableHeaderStyle())),
                DataColumn(label: Text("Genre", style: _tableHeaderStyle())),
                DataColumn(label: Text("Pages", style: _tableHeaderStyle())),
                DataColumn(label: Text("Year", style: _tableHeaderStyle())),
                DataColumn(label: Text("State", style: _tableHeaderStyle())),
                DataColumn(label: Icon(Icons.info_outline, color: Color(0xFF8D6748))),
                DataColumn(label: Icon(Icons.edit, color: Color(0xFF8D6748))),
                DataColumn(label: Icon(Icons.delete, color: Colors.red)),
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
                  DataCell(Text(e.title, style: _tableCellStyle())),
                  DataCell(Text(e.authorName, style: _tableCellStyle())),
                  DataCell(Text(e.genres.join(', '), style: _tableCellStyle())),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetails(book: e, isEditMode: false,),
                        ),
                      );
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
                      
                      // Refresh the book list if edit was successful
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
                          content: const Text('Are you sure you want to delete this book?'),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                try {
                                  await bookProvider.delete(e.id);
                                  Navigator.pop(context);
                                  // Refresh the book list after successful deletion
                                  _fetchAllBooks();
                                } catch (error) {
                                  // Show error message if deletion fails
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.error, color: Colors.white),
                                          SizedBox(width: 12),
                                          Text("Failed to delete book: ${error.toString()}"),
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
          ),
        ),
      ),
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
}