import 'package:flutter/material.dart';
import 'package:bookworm_mobile/providers/book_club_provider.dart';
import 'package:bookworm_mobile/model/book_club.dart';
import 'package:bookworm_mobile/screens/book_club_details.dart';
import 'dart:async';

class BookClubsScreen extends StatefulWidget {
  final int currentUserId;
  const BookClubsScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<BookClubsScreen> createState() => _BookClubsScreenState();
}

class _BookClubsScreenState extends State<BookClubsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookClubProvider _bookClubProvider = BookClubProvider();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _myClubsSearchController = TextEditingController();
  List<BookClub> _allClubs = [];
  List<BookClub> _filteredClubs = [];
  List<BookClub> _myClubs = [];
  List<BookClub> _filteredMyClubs = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _sortByMembers = false;
  
  int _allClubsCurrentPage = 0;
  int _allClubsTotalCount = 0;
  bool _allClubsHasMoreData = true;
  static const int _pageSize = 10;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  
  int _myClubsCurrentPage = 0;
  int _myClubsTotalCount = 0;
  bool _myClubsHasMoreData = true;
  
  final ScrollController _scrollController = ScrollController();
  final ScrollController _myClubsScrollController = ScrollController();
  
  Timer? _searchDebounceTimer;
  Timer? _myClubsSearchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _resetPagination();
    _loadClubs();
    _loadMyClubs(); 
    
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      if (_tabController.index == 1) {
        if (_searchController.text.isNotEmpty) {
          _searchController.clear();
          _searchDebounceTimer?.cancel();
          _onSearchChanged('');
        }
        if (_myClubsSearchController.text.isNotEmpty) {
          _myClubsSearchController.clear();
          _myClubsSearchDebounceTimer?.cancel();
          _onMyClubsSearchChanged('');
        }
        _loadMyClubs();
      } else if (_tabController.index == 0) {
        if (_searchController.text.isNotEmpty) {
          _searchController.clear();
          _searchDebounceTimer?.cancel();
          _onSearchChanged('');
        }
        if (_myClubsSearchController.text.isNotEmpty) {
          _myClubsSearchController.clear();
          _myClubsSearchDebounceTimer?.cancel();
          _onMyClubsSearchChanged('');
        }
        // Reset to page 0 when switching back to all clubs tab
        _loadClubs(page: 0);
      }
    }
  }


  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    
    if (_searchController.text.isNotEmpty) {
      // If searching, refresh search results
      await _loadClubsWithSearch(_searchController.text);
    } else {
      // Otherwise refresh normal results
      await _loadClubs(page: 0);
    }
    await _loadMyClubs(); 
    
    setState(() {
      _isRefreshing = false;
    });
  }

  Future<void> _loadClubs({int? page}) async {
    final targetPage = (page ?? _allClubsCurrentPage).clamp(0, double.infinity).toInt();
    
    setState(() {
      if (targetPage == 0) {
        _isLoading = true;
        _errorMessage = null;
      } else {
        _isLoadingMore = true;
      }
      _allClubs.clear();
      _filteredClubs.clear();
    });
    
    _ensureValidPageNumbers();
    
    try {
      final filter = <String, dynamic>{
        'pageSize': _pageSize,
        'page': targetPage,
        'includeTotalCount': true,
      };
      
      final result = await _bookClubProvider.get(filter: filter);
      final allClubs = result.items ?? [];
      
      setState(() {
        _allClubs = allClubs;
        _filteredClubs = allClubs;
        
        _allClubsCurrentPage = targetPage;
        _allClubsTotalCount = (result.totalCount ?? 0).clamp(0, double.infinity).toInt();
        final nextPageStart = (targetPage + 1) * _pageSize;
        _allClubsHasMoreData = nextPageStart < _allClubsTotalCount && _allClubsTotalCount > 0 && _pageSize > 0;
        
        if (allClubs.isEmpty && targetPage > 0) {
          _allClubsCurrentPage = (targetPage - 1).clamp(0, double.infinity).toInt();
          _allClubsHasMoreData = false;
        }
        _ensureValidPageNumbers();
        
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load book clubs: ${e.toString()}';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    
    // If empty, immediately reset to show all clubs
    if (value.isEmpty) {
      _performSearch(value);
      return;
    }
    
    // For non-empty values, use longer debouncing to prevent keyboard dismissal
    _searchDebounceTimer = Timer(const Duration(milliseconds: 800), () {
      _performSearch(value);
    });
  }

  void _performSearch(String value) {
    if (value.isEmpty) {
      // If search is empty, load all clubs from page 0
      _loadClubs(page: 0);
    } else if (value.trim().length < 2) {
      // If search is too short, show all clubs
      _loadClubs(page: 0);
    } else {
      // If search has content, search across all clubs
      _loadClubsWithSearch(value.trim());
    }
  }

  Future<void> _loadClubsWithSearch(String searchTerm, {int? page}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final filter = <String, dynamic>{
        'RetrieveAll': true, // Get all results without pagination
        'includeTotalCount': true,
        'name': searchTerm, // Use API search parameter
      };
      
      final result = await _bookClubProvider.get(filter: filter);
      final searchResults = result.items ?? [];
      
      setState(() {
        _allClubs = searchResults;
        _filteredClubs = searchResults;
        
        _allClubsCurrentPage = 0;
        _allClubsTotalCount = (result.totalCount ?? 0).clamp(0, double.infinity).toInt();
        _allClubsHasMoreData = false; // No pagination for search results
        
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to search book clubs: ${e.toString()}';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onMyClubsSearchChanged(String value) {
    _myClubsSearchDebounceTimer?.cancel();
    
    // If empty, immediately reset to show all clubs
    if (value.isEmpty) {
      setState(() {
        _filteredMyClubs = _myClubs;
      });
      _loadMyClubs(); // Reload without search filter
      return;
    }
    
    // For non-empty values, use longer debouncing to prevent keyboard dismissal
    _myClubsSearchDebounceTimer = Timer(const Duration(milliseconds: 800), () {
      _performMyClubsSearch(value);
    });
  }

  void _performMyClubsSearch(String value) {
    if (value.isEmpty) {
      setState(() {
        _filteredMyClubs = _myClubs;
      });
      _loadMyClubs(); // Reload without search filter
    } else if (value.trim().length < 2) {
      setState(() {
        _filteredMyClubs = _myClubs;
      });
      _loadMyClubs(); // Reload without search filter
    } else {
      _loadMyClubsWithSearch(value.trim());
    }
  }

  Future<void> _loadMyClubsWithSearch(String searchTerm) async {
    try {
      final filter = <String, dynamic>{
        'RetrieveAll': true, // Get all results without pagination
        'includeTotalCount': true,
        'isMember': true, // Use API filter to get only user's clubs
        'name': searchTerm, // Use API search parameter
      };
      
      final result = await _bookClubProvider.get(filter: filter);
      final searchResults = result.items ?? [];
      
      // Sort clubs: creators first, then alphabetically
      searchResults.sort((a, b) {
        if (a.isCreator && !b.isCreator) return -1;
        if (!a.isCreator && b.isCreator) return 1;
        return a.name.compareTo(b.name);
      });
      
      setState(() {
        _filteredMyClubs = searchResults;
      });
    } catch (e) {
      print('Failed to search my clubs: ${e.toString()}');
      // Fallback to client-side search
      setState(() {
        _filteredMyClubs = _myClubs.where((club) => 
          club.name.toLowerCase().contains(searchTerm.toLowerCase())
        ).toList();
      });
    }
  }

  void _resetPagination() {
    setState(() {
      _allClubsCurrentPage = 0;
      _allClubsHasMoreData = true;
      _myClubsCurrentPage = 0;
      _myClubsHasMoreData = true;
      _errorMessage = null;
    });
  }

  void _ensureValidPageNumbers() {
    if (_allClubsCurrentPage < 0) _allClubsCurrentPage = 0;
    if (_myClubsCurrentPage < 0) _myClubsCurrentPage = 0;
    
    if (_searchController.text.isNotEmpty) {
      _allClubsCurrentPage = 0;
      return;
    }
    
    final totalPages = (_pageSize > 0) ? (_allClubsTotalCount / _pageSize).ceil() : 1;
    if (_allClubsCurrentPage >= totalPages && totalPages > 0) {
      _allClubsCurrentPage = totalPages - 1;
    }
  }





  void _handleNoMoreData() {
    setState(() {
      _allClubsHasMoreData = false;
    });
  }

  Widget _buildEndOfListIndicator() {
    if (!_allClubsHasMoreData && _filteredClubs.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const Center(
          child: Text(
            'You\'ve reached the end of the list',
            style: TextStyle(
              color: Color(0xFF8D6748),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _toggleSortByMembers() {
    setState(() {
      _sortByMembers = !_sortByMembers;
      if (_sortByMembers) {
        _filteredClubs.sort((a, b) => b.membersCount.compareTo(a.membersCount));
        _filteredMyClubs.sort((a, b) => b.membersCount.compareTo(a.membersCount));
      } else {
        _filteredClubs.sort((a, b) => a.name.compareTo(b.name));
        _filteredMyClubs.sort((a, b) {
          if (a.isCreator && !b.isCreator) return -1;
          if (!a.isCreator && b.isCreator) return 1;
          return a.name.compareTo(b.name);
        });
      }
    });
  }



  void _navigateToNextPage() {
    if (_searchController.text.isNotEmpty) {
      // For search results, no pagination - all results are already loaded
      return;
    }
    
    if (_allClubsHasMoreData && !_isLoadingMore && !_isLoading) {
      final nextPage = (_allClubsCurrentPage + 1).clamp(0, double.infinity).toInt();
      _loadClubs(page: nextPage);
    }
  }

  void _navigateToPreviousPage() {
    if (_searchController.text.isNotEmpty) {
      // For search results, no pagination - all results are already loaded
      return;
    }
    
    if (_allClubsCurrentPage > 0 && !_isLoading) {
      final prevPage = (_allClubsCurrentPage - 1).clamp(0, double.infinity).toInt();
      _loadClubs(page: prevPage);
    }
  }

  void _navigateToPage(int page) {
    if (_searchController.text.isNotEmpty) {
      // For search results, no pagination - all results are already loaded
      return;
    }
    
    final safePage = page.clamp(0, double.infinity).toInt();
    final totalPages = _pageSize > 0 ? (_allClubsTotalCount / _pageSize).ceil() : 1;
    if (safePage >= 0 && safePage < totalPages && !_isLoading) {
      _loadClubs(page: safePage);
    }
  }

  

  // This method is no longer needed as we now use API search
  // Future<void> _loadAllClubsForSearch() async {
  //   // Removed as search now uses API parameters
  // }

  Future<void> _loadMyClubs() async {
    try {
      final filter = <String, dynamic>{
        'pageSize': 100, // Use a reasonable page size
        'page': 0,
        'includeTotalCount': true,
        'isMember': true, // Use API filter to get only user's clubs
      };
      
      final result = await _bookClubProvider.get(filter: filter);
      final myClubs = result.items ?? [];
      
      // Sort clubs: creators first, then alphabetically
      myClubs.sort((a, b) {
        if (a.isCreator && !b.isCreator) return -1;
        if (!a.isCreator && b.isCreator) return 1;
        return a.name.compareTo(b.name);
      });
      
      setState(() {
        _myClubs = myClubs;
        // Only update filtered list if there's no active search
        if (_myClubsSearchController.text.isEmpty) {
          _filteredMyClubs = myClubs;
        }
      });
    } catch (e) {
      print('Failed to load my clubs: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _myClubsSearchController.dispose();
    _scrollController.dispose();
    _myClubsScrollController.dispose();
    _searchDebounceTimer?.cancel();
    _myClubsSearchDebounceTimer?.cancel();
    super.dispose();
  }

  Widget _buildPaginationControls() {
    if (_allClubsTotalCount == 0 || _filteredClubs.isEmpty || _errorMessage != null) {
      return const SizedBox.shrink();
    }
    
    // Don't show pagination controls for search results as they are handled differently
    if (_searchController.text.isNotEmpty) {
      return const SizedBox.shrink();
    }
    
    final effectiveTotalCount = _allClubsTotalCount;
    final totalPages = _pageSize > 0 ? (effectiveTotalCount / _pageSize).ceil() : 1;
    final currentPageNumber = (_allClubsCurrentPage + 1).clamp(1, totalPages);
    
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }
    
    if (_isLoading || _isLoadingMore) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                color: Color(0xFF8D6748),
              ),
              SizedBox(height: 8),
              Text(
                'Loading page...',
                style: TextStyle(
                  color: Color(0xFF8D6748),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        border: Border(
          top: BorderSide(color: const Color(0xFFE0C9A6), width: 1),
        ),
      ),
      child: Column(
        children: [

          Column(
            children: [
              Center(
                child: Text(
                  'Page $currentPageNumber of $totalPages',
                  style: const TextStyle(
                    color: Color(0xFF8D6748),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _isRefreshing ? null : _refreshData,
                    icon: _isRefreshing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF8D6748),
                          ),
                        )
                      : const Icon(
                          Icons.refresh,
                          color: Color(0xFF8D6748),
                          size: 20,
                        ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    tooltip: 'Refresh',
                  ),
                  
                  const SizedBox(width: 8),
                  
                  if (_allClubsCurrentPage > 0)
                    IconButton(
                      onPressed: _isLoading ? null : _navigateToPreviousPage,
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF8D6748),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8D6748),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$currentPageNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  Text(
                    'of $totalPages',
                    style: const TextStyle(
                      color: Color(0xFF8D6748),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  if (_allClubsCurrentPage < totalPages - 1)
                    IconButton(
                      onPressed: _isLoadingMore ? null : _navigateToNextPage,
                      icon: _isLoadingMore 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF8D6748),
                            ),
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF8D6748),
                            size: 20,
                          ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                ],
              ),
            ],
          ),
          
          if (totalPages > 3)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Go to page: ',
                    style: const TextStyle(
                      color: Color(0xFF8D6748),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 60,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE0C9A6)),
                    ),
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8D6748),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        hintText: '1',
                        hintStyle: TextStyle(
                          color: Color(0xFF8D6748),
                          fontSize: 12,
                        ),
                      ),
                      onSubmitted: (value) {
                        final page = int.tryParse(value);
                        if (page != null && page > 0 && page <= totalPages) {
                          _navigateToPage(page - 1); 
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'of $totalPages',
                    style: const TextStyle(
                      color: Color(0xFF8D6748),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(TextEditingController controller, VoidCallback onSortPressed, bool isSorted) {
    final isSearching = controller.text.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                autofocus: false,
                enableInteractiveSelection: true,
                onChanged: controller == _searchController ? _onSearchChanged : _onMyClubsSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search book clubs...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8D6748), size: 20),
                  suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF8D6748), size: 20),
                        onPressed: () {
                          controller.clear();
                          if (controller == _searchController) {
                            _searchDebounceTimer?.cancel();
                            _onSearchChanged('');
                          } else {
                            _myClubsSearchDebounceTimer?.cancel();
                            _onMyClubsSearchChanged('');
                          }
                        },
                      )
                    : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: isSorted ? const Color(0xFF8D6748) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onSortPressed,
              icon: Icon(
                Icons.sort,
                color: isSorted ? Colors.white : const Color(0xFF8D6748),
                size: 20,
              ),
              tooltip: isSorted ? 'Sort alphabetically' : 'Sort by number of members (highest first)',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard(BookClub club) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookClubDetailsScreen(bookClub: club),
              ),
            );
            _resetPagination();
            _loadClubs();
            _loadMyClubs(); 
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        club.name, 
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFF5D4037),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (club.isCreator)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8D6748),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Creator',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  club.description, 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis, 
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.people, color: const Color(0xFF8D6748), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${club.membersCount} members',
                      style: const TextStyle(
                        color: Color(0xFF8D6748),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (club.isCreator) ...[
                      IconButton(
                        onPressed: () => _editBookClub(club),
                        icon: const Icon(Icons.edit, color: Color(0xFF8D6748), size: 18),
                        tooltip: 'Edit Book Club',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _deleteBookClub(club),
                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                        tooltip: 'Delete Book Club',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(Icons.arrow_forward_ios, color: const Color(0xFF8D6748), size: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 4),
                TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF8D6748),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFF8D6748),
                  unselectedLabelColor: const Color(0xFF5D4037),
                  labelStyle: const TextStyle(
                    fontFamily: 'Literata', 
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Literata', 
                    fontWeight: FontWeight.w500, 
                    fontSize: 16,
                  ),
                  tabs: const [
                    Tab(text: 'All Book Clubs'),
                    Tab(text: 'My Book Clubs'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    Column(
                      children: [
                        _buildSearchBar(_searchController, _toggleSortByMembers, _sortByMembers),
                        if (_searchController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              '${_filteredClubs.length} book club${_filteredClubs.length == 1 ? '' : 's'} found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        Expanded(
                          child: _filteredClubs.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isLoading ? Icons.hourglass_empty : Icons.group_outlined, 
                                        size: 64, 
                                        color: const Color(0xFF8D6748)
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _isLoading 
                                          ? 'Loading book clubs...'
                                          : _errorMessage ?? 'No book clubs found.',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFF8D6748),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (_errorMessage != null) ...[
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _refreshData,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF8D6748),
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _refreshData,
                                  color: const Color(0xFF8D6748),
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                                      itemCount: _filteredClubs.isEmpty || _isLoading || _errorMessage != null ? 0 : _filteredClubs.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index >= _filteredClubs.length) {
                                          if (index == _filteredClubs.length && _filteredClubs.isNotEmpty && !_isLoading && _errorMessage == null) {
                                            return _buildPaginationControls();
                                          }
                                          return const SizedBox.shrink();
                                        }
                                        return _buildClubCard(_filteredClubs[index]);
                                      },
                                    ),
                                  ),
                                ),
                    )],
                    ),
                    Column(
                      children: [
                        _buildSearchBar(_myClubsSearchController, _toggleSortByMembers, _sortByMembers),
                        if (_myClubsSearchController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              '${_filteredMyClubs.length} book club${_filteredMyClubs.length == 1 ? '' : 's'} found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        Expanded(
                          child: _filteredMyClubs.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isLoading ? Icons.hourglass_empty : Icons.book_outlined, 
                                        size: 64, 
                                        color: const Color(0xFF8D6748)
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _isLoading 
                                          ? 'Loading your book clubs...'
                                          : _errorMessage ?? 'You are not a member of any book clubs.',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFF8D6748),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (_errorMessage != null) ...[
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _refreshData,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF8D6748),
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _refreshData,
                                  color: const Color(0xFF8D6748),
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    child: ListView.builder(
                                      controller: _myClubsScrollController,
                                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                                      itemCount: _filteredMyClubs.length,
                                      itemBuilder: (context, index) {
                                        return _buildClubCard(_filteredMyClubs[index]);
                                      },
                                    ),
                                  ),
                                ),
                    )],
                    ),
                  ],
                ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton(
          onPressed: () {
            _showCreateBookClubDialog();
          },
          backgroundColor: const Color(0xFF8D6748),
          elevation: 8,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  void _showCreateBookClubDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? nameError;
    String? descriptionError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Book Club'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Book Club Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        if (value.length > 100) {
                          return 'Name must be less than 100 characters';
                        }
                        // Note: Duplicate check is done in the button's onPressed
                        return null;
                      },
                    ),
                    if (nameError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          nameError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description is required';
                        }
                        if (value.length > 500) {
                          return 'Description must be less than 500 characters';
                        }
                        return null;
                      },
                    ),
                    if (descriptionError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          descriptionError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Clear previous errors
              setDialogState(() {
                nameError = null;
                descriptionError = null;
              });
              
              // Check for duplicate names by fetching all book clubs
              try {
                final allClubsResult = await _bookClubProvider.get(filter: {'RetrieveAll': true});
                final allClubs = allClubsResult.items ?? [];
                
                if (allClubs.any((club) => club.name.toLowerCase() == nameController.text.toLowerCase())) {
                  setDialogState(() {
                    nameError = 'A book club with this name already exists';
                  });
                  return;
                }
              } catch (e) {
                // If we can't check for duplicates, continue anyway
                print('Could not check for duplicate names: $e');
              }
              
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                await _createBookClub(nameController.text, descriptionController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8D6748),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    ),
  );
  }

  Future<void> _createBookClub(String name, String description) async {
    try {
      final newBookClub = await _bookClubProvider.createBookClub(name, description);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book club created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _resetPagination();
      _loadClubs();
      _loadMyClubs(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create book club: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editBookClub(BookClub club) async {
    final nameController = TextEditingController(text: club.name);
    final descriptionController = TextEditingController(text: club.description);
    final formKey = GlobalKey<FormState>();
    String? nameError;
    String? descriptionError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Book Club'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Book Club Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        if (value.length > 100) {
                          return 'Name must be less than 100 characters';
                        }
                        // Note: Duplicate check is done in the button's onPressed
                        return null;
                      },
                    ),
                    if (nameError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          nameError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description is required';
                        }
                        if (value.length > 500) {
                          return 'Description must be less than 500 characters';
                        }
                        return null;
                      },
                    ),
                    if (descriptionError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          descriptionError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Clear previous errors
                setDialogState(() {
                  nameError = null;
                  descriptionError = null;
                });
                
                // Check for duplicate names by fetching all book clubs
                try {
                  final allClubsResult = await _bookClubProvider.get(filter: {'RetrieveAll': true});
                  final allClubs = allClubsResult.items ?? [];
                  
                  if (allClubs.any((otherClub) => 
                      otherClub.id != club.id && 
                      otherClub.name.toLowerCase() == nameController.text.toLowerCase())) {
                    setDialogState(() {
                      nameError = 'A book club with this name already exists';
                    });
                    return;
                  }
                } catch (e) {
                  // If we can't check for duplicates, continue anyway
                  print('Could not check for duplicate names: $e');
                }
                
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  await _updateBookClub(club.id, nameController.text, descriptionController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8D6748),
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateBookClub(int id, String name, String description) async {
    try {
      await _bookClubProvider.updateBookClub(id, name, description);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book club updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _resetPagination();
      _loadClubs();
      _loadMyClubs(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update book club: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteBookClub(BookClub club) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book Club'),
        content: Text('Are you sure you want to delete "${club.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDeleteBookClub(club.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteBookClub(int id) async {
    try {
      await _bookClubProvider.deleteBookClub(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book club deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _resetPagination();
      _loadClubs();
      _loadMyClubs(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete book club: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
