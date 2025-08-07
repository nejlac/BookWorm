import 'package:flutter/material.dart';
import 'package:bookworm_mobile/providers/book_club_provider.dart';
import 'package:bookworm_mobile/model/book_club.dart';
import 'package:bookworm_mobile/screens/book_club_details.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final allClubs = await _bookClubProvider.getAllBookClubs();
      final myClubs = allClubs.where((club) => club.isMember || club.isCreator).toList();
      
      myClubs.sort((a, b) {
        if (a.isCreator && !b.isCreator) return -1;
        if (!a.isCreator && b.isCreator) return 1;
        return a.name.compareTo(b.name);
      });
      
      setState(() {
        _allClubs = allClubs;
        _filteredClubs = allClubs;
        _myClubs = myClubs;
        _filteredMyClubs = myClubs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load book clubs.';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _filteredClubs = _allClubs.where((club) => club.name.toLowerCase().contains(value.toLowerCase())).toList();
    });
  }

  void _onMyClubsSearchChanged(String value) {
    setState(() {
      _filteredMyClubs = _myClubs.where((club) => club.name.toLowerCase().contains(value.toLowerCase())).toList();
    });
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

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _myClubsSearchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar(TextEditingController controller, VoidCallback onSortPressed, bool isSorted) {
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
                onChanged: controller == _searchController ? _onSearchChanged : _onMyClubsSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search book clubs...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8D6748), size: 20),
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
            _loadClubs();
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
                    _filteredClubs.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.group_outlined, size: 64, color: Color(0xFF8D6748)),
                                SizedBox(height: 16),
                                Text(
                                  'No book clubs found.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF8D6748),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.only(top: 8, bottom: 100),
                            children: [
                              _buildSearchBar(_searchController, _toggleSortByMembers, _sortByMembers),
                              ..._filteredClubs.map(_buildClubCard).toList(),
                            ],
                          ),
                    _filteredMyClubs.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.book_outlined, size: 64, color: Color(0xFF8D6748)),
                                SizedBox(height: 16),
                                Text(
                                  'You are not a member of any book clubs.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF8D6748),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.only(top: 8, bottom: 100),
                            children: [
                              _buildSearchBar(_myClubsSearchController, _toggleSortByMembers, _sortByMembers),
                              ..._filteredMyClubs.map(_buildClubCard).toList(),
                            ],
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                      if (_allClubs.any((club) => club.name.toLowerCase() == value.toLowerCase())) {
                        return 'A book club with this name already exists';
                      }
                      return null;
                    },
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
      _loadClubs();
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                      if (_allClubs.any((otherClub) => 
                          otherClub.id != club.id && 
                          otherClub.name.toLowerCase() == value.toLowerCase())) {
                        return 'A book club with this name already exists';
                      }
                      return null;
                    },
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
      _loadClubs();
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
      _loadClubs();
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
