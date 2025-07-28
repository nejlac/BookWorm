import 'package:bookworm_mobile/model/author.dart';
import 'package:bookworm_mobile/providers/author_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/book.dart';
import '../model/genre.dart';
import '../model/user.dart';
import '../model/country.dart';
import '../providers/book_provider.dart';
import '../providers/genre_provider.dart';
import '../providers/user_provider.dart';
import '../providers/country_provider.dart';
import '../providers/base_provider.dart';
import 'user_profile.dart';
import 'author_details.dart';
import 'book_details.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final BookProvider _bookProvider = BookProvider();
  final GenreProvider _genreProvider = GenreProvider();
  final UserProvider _userProvider = UserProvider();
  final CountryProvider _countryProvider = CountryProvider();
  final AuthorProvider _authorProvider = AuthorProvider();
  
  List<Book> _books = [];
  List<Genre> _genres = [];
  List<User> _users = [];
  List<String> _years = [];
  List<String> _sizes = [];
  List<Author> _authors = [];
  
  
  int _currentPage = 0;
  int _totalCount = 0;
  bool _hasMoreData = true;
  static const int _pageSize = 10;
  
  Genre? _selectedGenre;
  String? _selectedYear;
  String? _selectedSize;
  Country? _selectedCountry;
  String? _selectedSort; 
  String _selectedTab = 'Books';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _onTabChanged(_tabController.index);
      }
    });
    _loadGenres();
    _loadBooks();
    _loadAuthors();
    _loadUsers();
    _generateYears();
    _generateSizes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when screen becomes visible again
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  void _refreshData() {
    if (_selectedTab == 'Books') {
      _loadBooks();
    } else if (_selectedTab == 'Authors') {
      _loadAuthors();
    } else if (_selectedTab == 'Users') {
      _loadUsers();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _generateYears() {
    final currentYear = DateTime.now().year;
    _years = List.generate(50, (index) => (currentYear - index).toString());
  }

  void _generateSizes() {
    _sizes = [
      'Any Size',
      '0-100 pages',
      '101-300 pages',
      '301-500 pages',
      '500+ pages',
    ];
  }

  Future<void> _loadGenres() async {
    try {
      final genres = await _genreProvider.getAllGenres();
      setState(() {
        _genres = genres;
      });
    } catch (e) {
      print('Error loading genres: $e');
    }
  }


  Future<void> _loadAuthors({int? page}) async {
    final targetPage = page ?? _currentPage;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final filter = <String, dynamic>{
        'pageSize': _pageSize,
        'page': targetPage,
        'includeTotalCount': true,
      };

      if (_searchController.text.isNotEmpty) {
        filter['name'] = _searchController.text.trim();
      }
      if (_selectedCountry != null) {
        filter['countryId'] = _selectedCountry!.id;
      }


      final result = await _authorProvider.get(filter: filter);
      setState(() {
        _authors = result.items ?? [];
        _currentPage = targetPage;
        _totalCount = result.totalCount ?? 0;
        _hasMoreData = (_authors.length < _totalCount);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }



  Future<void> _loadBooks({int? page}) async {
    final targetPage = page ?? _currentPage;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final filter = <String, dynamic>{
        'pageSize': _pageSize,
        'page': targetPage,
        'includeTotalCount': true,
      };

     
      if (_searchController.text.isNotEmpty) {
        filter['title'] = _searchController.text.trim();
      }
      if (_selectedGenre != null) {
        filter['genreId'] = _selectedGenre!.id;
      }
      if (_selectedYear != null && _selectedYear != 'Any Year') {
        filter['publicationYear'] = int.tryParse(_selectedYear!);
      }
      
      if (_selectedSize != null && _selectedSize != 'Any Size') {
        final sizeRange = _selectedSize!;
        if (sizeRange == '0-100 pages') {
          filter['minPageCount'] = 0;
          filter['maxPageCount'] = 100;
        } else if (sizeRange == '101-300 pages') {
          filter['minPageCount'] = 101;
          filter['maxPageCount'] = 300;
        } else if (sizeRange == '301-500 pages') {
          filter['minPageCount'] = 301;
          filter['maxPageCount'] = 500;
        } else if (sizeRange == '500+ pages') {
          filter['minPageCount'] = 500;
        }
      }
      
      if (_selectedSort != null) {
        filter['sortBy'] = _selectedSort;
      }

      final result = await _bookProvider.get(filter: filter);
      setState(() {
        _books = result.items ?? [];
        _currentPage = targetPage;
        _totalCount = result.totalCount ?? 0;
        _hasMoreData = (_books.length < _totalCount);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUsers({int? page}) async {
    final targetPage = page ?? _currentPage;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final filter = <String, dynamic>{
        'pageSize': _pageSize,
        'page': targetPage,
        'includeTotalCount': true,
      };

      
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.trim();
       
        filter['username'] = searchTerm;
       
      }
      if (_selectedCountry != null) {
        filter['countryId'] = _selectedCountry!.id;
      }

      final result = await _userProvider.get(filter: filter);
      setState(() {
        _users = result.items ?? [];
        _currentPage = targetPage;
        _totalCount = result.totalCount ?? 0;
        _hasMoreData = (_users.length < _totalCount);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
   
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == value) {
        if (_selectedTab == 'Books') {
          _loadBooks();
        } else if (_selectedTab == 'Users') {
          _loadUsers();
        }
        else if (_selectedTab == 'Authors') {
          _loadAuthors();
        }
      }
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTab = ['Books', 'Authors', 'Users'][index];
      _currentPage = 0; // Reset to first page when switching tabs
    });
    
   
    if (_selectedTab == 'Books') {
      _loadBooks();
    } else if (_selectedTab == 'Users') {
      _loadUsers();
    }
    else if (_selectedTab == 'Authors') {
          _loadAuthors();
        }
   
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
       
    const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: _selectedTab == 'Books' ? 'Type the name of the book' : 
                               _selectedTab == 'Users' ? 'Search by username' : 
                                _selectedTab == 'Authors' ? 'Search by name' : 
                               'Search...',
                      hintStyle: const TextStyle(color: Color(0xFF8D6748)),
                      prefixIcon: const Icon(Icons.menu, color: Color(0xFF8D6748)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Color(0xFF8D6748)),
                        onPressed: () {
                          if (_selectedTab == 'Books') {
                            _loadBooks(page: 0);
                          } else if (_selectedTab == 'Users') {
                            _loadUsers(page: 0);
                          } else if (_selectedTab == 'Authors') {
                            _loadAuthors(page: 0);
                          }
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              
              
              if (_selectedTab == 'Books') ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _buildFilterButton(
                    'Sort',
                    _selectedSort ?? 'No Sort',
                    Icons.sort,
                    () => _showSortFilter(),
                  ),
                ),
              ],
            ],
          ),
        ),

        
        const SizedBox(height: 2),

      
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _selectedTab == 'Books' ? Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterButton(
                      'Genre',
                      _selectedGenre?.name ?? 'Any Genre',
                      Icons.arrow_drop_down,
                      () => _showGenreFilter(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterButton(
                      'Year',
                      _selectedYear?.toString() ?? 'Any Year',
                      Icons.arrow_drop_down,
                      () => _showYearFilter(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterButton(
                      'Size',
                      _selectedSize ?? 'Any Size',
                      Icons.arrow_drop_down,
                      () => _showSizeFilter(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ) : _selectedTab == 'Users' ? Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterButton(
                      'Country',
                      _selectedCountry?.name ?? 'Any Country',
                      Icons.arrow_drop_down,
                      () => _showCountryFilter(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ):  _selectedTab == 'Authors' ? Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterButton(
                      'Country',
                      _selectedCountry?.name ?? 'Any Country',
                      Icons.arrow_drop_down,
                      () => _showCountryFilter(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ) : const SizedBox.shrink(),
        ),

        const SizedBox(height: 5),

      
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            onTap: _onTabChanged,
            indicator: BoxDecoration(
              color: const Color(0xFF8D6748),
              borderRadius: BorderRadius.circular(8),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF8D6748),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'Books', height: 48),
              Tab(text: 'Authors', height: 48),
              Tab(text: 'Users', height: 48),
            ],
          ),
        ),

        const SizedBox(height: 16),

       
        Expanded(
          child: _selectedTab == 'Books' ? _buildBooksList() : 
                 _selectedTab == 'Users' ? _buildUsersList() : 
                  _selectedTab == 'Authors' ? _buildAuthorsList() : 
                 _buildPlaceholderContent(),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0C9A6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8D6748),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(icon, color: const Color(0xFF8D6748), size: 18),
          ],
        ),
      ),
    );
  }

  void _showGenreFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8E1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Genre',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF8D6748)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Any Genre'),
                    onTap: () {
                      setState(() => _selectedGenre = null);
                      Navigator.pop(context);
                      _loadBooks();
                    },
                  ),
                  ..._genres.map((genre) => ListTile(
                    title: Text(genre.name),
                    onTap: () {
                      setState(() => _selectedGenre = genre);
                      Navigator.pop(context);
                      _loadBooks();
                    },
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showYearFilter() {
    final TextEditingController yearController = TextEditingController(text: _selectedYear ?? '');
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF8E1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enter Year',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF8D6748)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter publication year (e.g., 2020)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _selectedYear = null);
                          Navigator.pop(context);
                          _loadBooks();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE0C9A6),
                          foregroundColor: const Color(0xFF5D4037),
                        ),
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final year = yearController.text.trim();
                          if (year.isNotEmpty) {
                            setState(() => _selectedYear = year);
                          } else {
                            setState(() => _selectedYear = null);
                          }
                          Navigator.pop(context);
                          _loadBooks();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D6748),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSizeFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8E1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Size',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF8D6748)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: _sizes.map((size) => ListTile(
                  title: Text(size),
                  onTap: () {
                    setState(() => _selectedSize = size);
                    Navigator.pop(context);
                    _loadBooks();
                  },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8E1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF8D6748)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('No Sort'),
                    onTap: () {
                      setState(() => _selectedSort = null);
                      Navigator.pop(context);
                      _loadBooks(page: 0);
                    },
                  ),
                  ListTile(
                    title: const Text('Rating (High to Low)'),
                    onTap: () {
                      setState(() => _selectedSort = 'rating_desc');
                      Navigator.pop(context);
                      _loadBooks(page: 0);
                    },
                  ),
                  ListTile(
                    title: const Text('Rating (Low to High)'),
                    onTap: () {
                      setState(() => _selectedSort = 'rating_asc');
                      Navigator.pop(context);
                      _loadBooks(page: 0);
                    },
                  ),
                  ListTile(
                    title: const Text('Title (A-Z)'),
                    onTap: () {
                      setState(() => _selectedSort = 'title_asc');
                      Navigator.pop(context);
                      _loadBooks(page: 0);
                    },
                  ),
                  ListTile(
                    title: const Text('Title (Z-A)'),
                    onTap: () {
                      setState(() => _selectedSort = 'title_desc');
                      Navigator.pop(context);
                      _loadBooks(page: 0);
                    },
                  ),
                  ListTile(
                    title: const Text('Publication Year (Newest)'),
                    onTap: () {
                      setState(() => _selectedSort = 'year_desc');
                      Navigator.pop(context);
                      _loadBooks(page: 0);
                    },
                  ),
                  ListTile(
                    title: const Text('Publication Year (Oldest)'),
                    onTap: () {
                      setState(() => _selectedSort = 'year_asc');
                      Navigator.pop(context);
                      _loadBooks(page: 0);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8E1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Country',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF8D6748)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<void>(
                future: _countryProvider.fetchCountries(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final countries = _countryProvider.countries;
                  return ListView(
                    children: [
                      ListTile(
                        title: const Text('Any Country'),
                        onTap: () {
                          setState(() => _selectedCountry = null);
                          Navigator.pop(context);
                          if (_selectedTab == 'Users') {
                            _loadUsers();
                          } else if (_selectedTab == 'Authors') {
                            _loadAuthors();
                          }
                        },
                      ),
                      ...countries.map((country) => ListTile(
                        title: Text(country.name),
                        onTap: () {
                          setState(() => _selectedCountry = country);
                          Navigator.pop(context);
                          if (_selectedTab == 'Users') {
                            _loadUsers();
                          } else if (_selectedTab == 'Authors') {
                            _loadAuthors();
                          }
                        },
                      )),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8D6748),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Color(0xFF8D6748), size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading books',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFF8D6748)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_books.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: Color(0xFF8D6748), size: 48),
            SizedBox(height: 16),
            Text(
              'No books found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria',
              style: TextStyle(color: Color(0xFF8D6748)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _books.length + (_books.isNotEmpty ? 1 : 0), 
      itemBuilder: (context, index) {
        if (index == _books.length) {
        
          return _buildPaginationControls();
        }
        final book = _books[index];
        return _buildBookCard(book);
      },
    );
  }

  Widget _buildBookCard(Book book) {
    String? imageUrl;
    if (book.coverImagePath != null && book.coverImagePath!.isNotEmpty) {
      if (book.coverImagePath!.startsWith('http')) {
        imageUrl = book.coverImagePath!;
      } else {
        String base = BaseProvider.baseUrl ?? '';
        if (base.endsWith('/api/')) {
          base = base.substring(0, base.length - 5);
        }
        imageUrl = '$base/${book.coverImagePath}';
      }
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(book: book),
          ),
        );
        // Refresh the books list to update ratings after returning from book details
        if (_selectedTab == 'Books') {
          _loadBooks(page: _currentPage);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
          children: [
            // Book Cover
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFE0C9A6),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.book,
                            color: Color(0xFF8D6748),
                            size: 30,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.book,
                      color: Color(0xFF8D6748),
                      size: 30,
                    ),
            ),
            const SizedBox(width: 12),
            // Book Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.authorName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8D6748),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<Map<String, dynamic>?>(
                    future: _getBookRating(book.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Row(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 16,
                              child: LinearProgressIndicator(
                                backgroundColor: Color(0xFFE0C9A6),
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8D6748)),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8D6748),
                              ),
                            ),
                          ],
                        );
                      }
                      
                      if (snapshot.hasError) {
                        return const Row(
                          children: [
                            Icon(Icons.star_border, color: Color(0xFFFFD700), size: 16),
                            SizedBox(width: 8),
                            Text(
                              'No ratings',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8D6748),
                              ),
                            ),
                          ],
                        );
                      }
                      
                      final ratingData = snapshot.data;
                      if (ratingData == null || ratingData['ratingCount'] == 0) {
                        return const Row(
                          children: [
                            Icon(Icons.star_border, color: Color(0xFFFFD700), size: 16),
                            SizedBox(width: 8),
                            Text(
                              'No ratings',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8D6748),
                              ),
                            ),
                          ],
                        );
                      }
                      
                      final averageRating = ratingData['averageRating'] as double;
                      final ratingCount = ratingData['ratingCount'] as int;
                      
                      return Row(
                        children: [
                        
                          Row(
                            children: List.generate(5, (index) {
                              if (index < averageRating.floor()) {
                               
                                return const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFD700),
                                  size: 16,
                                );
                              } else if (index == averageRating.floor() && averageRating % 1 > 0) {
                              
                                return const Icon(
                                  Icons.star_half,
                                  color: Color(0xFFFFD700),
                                  size: 16,
                                );
                              } else {
                             
                                return const Icon(
                                  Icons.star_border,
                                  color: Color(0xFFFFD700),
                                  size: 16,
                                );
                              }
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${ratingCount} Ratings',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8D6748),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Future<Map<String, dynamic>?> _getBookRating(int bookId) async {
    try {
      final url = '${BaseProvider.baseUrl ?? "http://10.0.2.2:7031/api/"}book/$bookId/rating';
      final uri = Uri.parse(url);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'averageRating': data['averageRating'].toDouble(),
          'ratingCount': data['ratingCount'],
        };
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching book rating: $e');
      return null;
    }
  }

  Widget _buildUsersList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8D6748),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Color(0xFF8D6748), size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading users',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFF8D6748)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, color: Color(0xFF8D6748), size: 48),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria',
              style: TextStyle(color: Color(0xFF8D6748)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _users.length + (_users.isNotEmpty ? 1 : 0), // +1 for pagination if users exist
      itemBuilder: (context, index) {
        if (index == _users.length) {
          // Pagination at the end
          return _buildPaginationControls();
        }
        final user = _users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(User user) {
    String? imageUrl;
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      if (user.photoUrl!.startsWith('http')) {
        imageUrl = user.photoUrl!;
      } else {
        String base = BaseProvider.baseUrl ?? '';
        if (base.endsWith('/api/')) {
          base = base.substring(0, base.length - 5);
        }
        imageUrl = '$base/${user.photoUrl}';
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(user: user),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // User Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0xFFE0C9A6),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Color(0xFF8D6748),
                              size: 30,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Color(0xFF8D6748),
                        size: 30,
                      ),
              ),
              const SizedBox(width: 12),
           
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user.username}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8D6748),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<String>(
                      future: _getCountryName(user.countryId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8D6748),
                            ),
                          );
                        }
                        return Text(
                          snapshot.data ?? 'Unknown Country',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8D6748),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF8D6748),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8D6748),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Color(0xFF8D6748), size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading authors',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFF8D6748)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_authors.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, color: Color(0xFF8D6748), size: 48),
            SizedBox(height: 16),
            Text(
              'No authors found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria',
              style: TextStyle(color: Color(0xFF8D6748)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _authors.length + (_authors.isNotEmpty ? 1 : 0), // +1 for pagination if authors exist
      itemBuilder: (context, index) {
        if (index == _authors.length) {
          // Pagination at the end
          return _buildPaginationControls();
        }
        final author = _authors[index];
        return _buildAuthorCard(author);
      },
    );
  }

  Widget _buildAuthorCard(Author author) {
    String? imageUrl;
    if (author.photoUrl != null && author.photoUrl!.isNotEmpty) {
      if (author.photoUrl!.startsWith('http')) {
        imageUrl = author.photoUrl!;
      } else {
        String base = BaseProvider.baseUrl ?? '';
        if (base.endsWith('/api/')) {
          base = base.substring(0, base.length - 5);
        }
        imageUrl = '$base/${author.photoUrl}';
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuthorDetailsScreen(author: author),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
             
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0xFFE0C9A6),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Color(0xFF8D6748),
                              size: 30,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Color(0xFF8D6748),
                        size: 30,
                      ),
              ),
              const SizedBox(width: 12),
           
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${author.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                   
                    FutureBuilder<String>(
                      future: _getCountryName(author.countryId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8D6748),
                            ),
                          );
                        }
                        return Text(
                          snapshot.data ?? 'Unknown Country',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8D6748),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF8D6748),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = (_totalCount / _pageSize).ceil();
    final currentPageNumber = _currentPage + 1;
   
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        border: Border(
          top: BorderSide(color: const Color(0xFFE0C9A6), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page info
          Text(
            'Page $currentPageNumber of $totalPages',
            style: const TextStyle(
              color: Color(0xFF8D6748),
              fontSize: 10,
            ),
          ),
          
          
          Row(
            children: [
            
              IconButton(
                onPressed: () {
                  _loadMoreData(_currentPage - 1);
                },
                icon: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF8D6748),
                  size: 16,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
              
              // Page indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF8D6748),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$currentPageNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              
              // Next button
              if (_currentPage < totalPages - 1)
                IconButton(
                  onPressed: () {
                    _loadMoreData(_currentPage + 1);
                  },
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF8D6748),
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
            ],
          ),
        ],
      ),
    );
  }

  int _getCurrentTabItemCount() {
    switch (_selectedTab) {
      case 'Books':
        return _books.length;
      case 'Users':
        return _users.length;
      case 'Authors':
        return _authors.length;
      default:
        return 0;
    }
  }

  void _loadMoreData(int page) {
    switch (_selectedTab) {
      case 'Books':
        _loadBooks(page: page);
        break;
      case 'Users':
        _loadUsers(page: page);
        break;
      case 'Authors':
        _loadAuthors(page: page);
        break;
    }
  }

  Future<String> _getCountryName(int countryId) async {
    try {
 
      if (_countryProvider.countries.isNotEmpty) {
        final country = _countryProvider.countries.firstWhere(
          (c) => c.id == countryId,
          orElse: () => Country(id: 0, name: 'Unknown Country'),
        );
        return country.name;
      }
      
  
      await _countryProvider.fetchCountries();
      final country = _countryProvider.countries.firstWhere(
        (c) => c.id == countryId,
        orElse: () => Country(id: 0, name: 'Unknown Country'),
      );
      return country.name;
    } catch (e) {
      return 'Unknown Country';
    }
  }

  Widget _buildPlaceholderContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, color: Color(0xFF8D6748), size: 48),
          SizedBox(height: 16),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Authors and Users search will be available soon',
            style: TextStyle(color: Color(0xFF8D6748)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
