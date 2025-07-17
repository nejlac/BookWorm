
import 'package:bookworm_desktop/model/author.dart';
import 'package:bookworm_desktop/model/search_result.dart';
import 'package:bookworm_desktop/providers/author_provider.dart';
import 'package:bookworm_desktop/providers/country_provider.dart';
import 'package:bookworm_desktop/providers/base_provider.dart';
import 'package:bookworm_desktop/screens/author_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AuthorList extends StatefulWidget {
  const AuthorList({super.key});

  @override
  State<AuthorList> createState() => _AuthorListState();
}

class _AuthorListState extends State<AuthorList> {
  late AuthorProvider authorProvider;
  late CountryProvider countryProvider;

  TextEditingController nameController = TextEditingController();
  List<Map<String, dynamic>> countries = [];
  Map<String, dynamic>? selectedCountry;
  SearchResult<Author>? Authors;

  int currentPage = 1;
  int pageSize = 14;
  int totalPages = 1;
  String? selectedStatus;
  final List<Map<String, dynamic>> statusOptions = [
    {'value': null, 'label': 'All'},
    {'value': 'Accepted', 'label': 'Accepted'},
    {'value': 'Submitted', 'label': 'Submitted'},
    {'value': 'Declined', 'label': 'Declined'},
  ];
  

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authorProvider = context.read<AuthorProvider>();
    countryProvider = Provider.of<CountryProvider>(context, listen: false);
    _fetchAllAuthors();
    _fetchCountries();
  }

  Future<void> _fetchAllAuthors({int? page}) async {
    try {
      final filter = {
        "includeTotalCount": true,
        "name": nameController.text.isNotEmpty ? nameController.text : null,
        "countryId": selectedCountry?['id'] ?? null,
        "page": (page ?? currentPage) -1,
        "pageSize": pageSize,
        "authorState": selectedStatus,
      };
      print("Author filter: $filter");
      Authors = await authorProvider.get(filter: filter);
      setState(() {
        this.Authors = Authors;
  currentPage = (page ?? currentPage);
  if (Authors?.totalCount != null && pageSize > 0) {
    totalPages = ((Authors!.totalCount! + pageSize - 1) ~/ pageSize);
    if (currentPage > totalPages) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;
  }
      });
    } catch (e) {
      debugPrint("Error fetching authors: $e");
    }
  }

 Future<void> _fetchCountries() async {
    try {
      await countryProvider.fetchCountries();
      var loadedCountries = countryProvider.countries;
      setState(() {
        countries = [{'id': null, 'name': 'All'}];
        countries.addAll(loadedCountries.map((c) => {'id': c.id, 'name': c.name}));
        selectedCountry = countries.first;
      });
    } catch (e) {
      setState(() {
        countries = [{'id': null, 'name': 'All'}];
        selectedCountry = countries.first;
      });
      debugPrint('Failed to load countries: ' + e.toString());
    }
  }

  Future<void> _initCountries() async {
    try {
      print('Fetching countries...');
      await countryProvider.fetchCountries();
      countries =countryProvider.countries
          .map((c) => {'id': c.id, 'name': c.name})
          .toList();  
      print('Loaded countries:  {countries.length}');
      setState(() {});
    } catch (e) {
      print('Failed to load countries: $e');
      countries = [];
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    countryProvider = Provider.of<CountryProvider>(context, listen: false);
    _initCountries();
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
            _buildAddAuthorButton(),
            _buildSearch(),
            _buildResultView(),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }
  
 
   Widget _buildSearch() {
    if (countries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No valid countries available',
          style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }
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
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Author Name',
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
                child: DropdownSearch<Map<String, dynamic>>(
                  items: countries,
                  itemAsString: (c) => c['name'] ?? '',
                  selectedItem: selectedCountry,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        labelText: 'Search country',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedCountry = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) return 'Country is required';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 2,
                child: DropdownButtonFormField<String?>(
                  value: selectedStatus,
                  items: statusOptions.map((s) => DropdownMenuItem<String?>(
                    value: s['value'],
                    child: Text(s['label'],
                      style: TextStyle(
                        color: s['value'] == 'Accepted'
                            ? Color(0xFF388E3C)
                            : s['value'] == 'Submitted'
                                ? Color(0xFFC62828)
                                : s['value'] == 'Declined'
                                    ? Colors.grey
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
                    _fetchAllAuthors(page: 1);
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
    if (Authors == null || Authors!.items == null || Authors!.items!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          'No authors found.',
          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: Authors!.items!.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // Adjust for your layout
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.62, // slightly tighter
              ),
              itemBuilder: (context, index) {
                final author = Authors!.items![index];
                final hasImage = author.photoUrl != null && author.photoUrl!.isNotEmpty;
                String? imageUrl;
                if (hasImage) {
                  if (author.photoUrl!.startsWith('http')) {
                    imageUrl = author.photoUrl!;
                  } else {
                    String base = BaseProvider.baseUrl ?? '';
                    if (base.endsWith('/api/')) {
                      base = base.substring(0, base.length - 5);
                    }
                    imageUrl = '$base/${author.photoUrl}';
                  }
                  print('[AuthorList] author.photoUrl: \\${author.photoUrl}');
                  print('[AuthorList] imageUrl: \\${imageUrl}');
                }
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthorDetails(author: author, isEditMode: false, isAddMode: false),
                      ),
                    );
                    if (result == true) _fetchAllAuthors(page: currentPage);
                  },
                  child: Stack(
                    children: [
                      Card(
                        color: const Color(0xFFFFF8E1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Color(0xFFD7CCC8), width: 2),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: hasImage && imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => _cutePlaceholder(),
                                      )
                                    : _cutePlaceholder(),
                              ),
                              SizedBox(height: 4),
                              Text(
                                author.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF4E342E),
                                  fontFamily: 'Literata',
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: author.authorState == 'Accepted'
                                      ? Color(0xFF388E3C).withOpacity(0.15)
                                      : author.authorState == 'Submitted'
                                          ? Color(0xFFC62828).withOpacity(0.15)
                                          : Colors.grey.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  author.authorState ?? '',
                                  style: TextStyle(
                                    color: author.authorState == 'Accepted'
                                        ? Color(0xFF388E3C)
                                        : author.authorState == 'Submitted'
                                            ? Color(0xFFC62828)
                                            : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Color(0xFF8D6748), size: 18),
                                    tooltip: 'Edit',
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AuthorDetails(author: author, isEditMode: true, isAddMode: false),
                                        ),
                                      );
                                      if (result == true) _fetchAllAuthors(page: currentPage);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Color(0xFFC62828), size: 18),
                                    tooltip: 'Delete',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Row(
                                            children: [
                                              Icon(Icons.warning, color: Color(0xFFC62828)),
                                              SizedBox(width: 8),
                                              Text('Delete Author'),
                                            ],
                                          ),
                                          content: Text('Are you sure you want to delete this author? This action cannot be undone.'),
                                          actions: [
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () => Navigator.of(context).pop(false),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFFC62828),
                                                foregroundColor: Colors.white,
                                              ),
                                              child: Text('Delete'),
                                              onPressed: () => Navigator.of(context).pop(true),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        final success = await authorProvider.delete(author.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(success ? Icons.check_circle : Icons.error, color: Colors.white),
                                                SizedBox(width: 12),
                                                Text(success ? 'Author deleted.' : 'Failed to delete author.'),
                                              ],
                                            ),
                                            backgroundColor: success ? Color(0xFF4CAF50) : Color(0xFFF44336),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        );
                                        if (success) _fetchAllAuthors(page: currentPage);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12),
          if (Authors!.totalCount != null && Authors!.totalCount! > 0)
            Text(
              'Total Authors: ${Authors!.totalCount}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
        ],
      ),
    );
  }

  Widget _cutePlaceholder() {
    return Container(
      height: 90,
      width: 90,
      decoration: BoxDecoration(
        color: Color(0xFFFFE0B2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          "📚", // Book emoji placeholder
          style: TextStyle(fontSize: 40),
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
                onPressed: currentPage > 1 ? () => _fetchAllAuthors(page: 1) : null,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              const SizedBox(width: 0),
              IconButton(
                icon: Icon(Icons.chevron_left, size: 20, color: currentPage == 1 ? Colors.grey : Color(0xFF8D6748)),
                tooltip: 'Previous Page',
                onPressed: currentPage > 1 ? () => _fetchAllAuthors(page: currentPage - 1) : null,
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
                    if (page != currentPage) _fetchAllAuthors(page: page);
                  },
                ),
              )),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 20, color: currentPage == totalPages ? Colors.grey : Color(0xFF8D6748)),
                tooltip: 'Next Page',
                onPressed: currentPage < totalPages ? () => _fetchAllAuthors(page: currentPage + 1) : null,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              const SizedBox(width: 0),
              IconButton(
                icon: Icon(Icons.last_page, size: 20, color: currentPage == totalPages ? Colors.grey : Color(0xFF8D6748)),
                tooltip: 'Last Page',
                onPressed: currentPage < totalPages ? () => _fetchAllAuthors(page: totalPages) : null,
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

  Widget _buildAddAuthorButton() {
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
                      builder: (context) => AuthorDetails(isEditMode: true, isAddMode: true),
                    ),
                  );
                  if (result == true) _fetchAllAuthors(page: 1);
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add an author',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8D6748),
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

}