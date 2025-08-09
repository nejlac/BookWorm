import 'package:bookworm_mobile/model/reading_list_book.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:bookworm_mobile/providers/reading_list_provider.dart';
import 'package:bookworm_mobile/model/reading_list.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:bookworm_mobile/screens/book_details.dart';
import 'package:bookworm_mobile/screens/search.dart';
import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import 'package:bookworm_mobile/model/book.dart'; 
import 'package:bookworm_mobile/providers/book_provider.dart';
import 'package:bookworm_mobile/providers/genre_provider.dart'; 
import 'package:bookworm_mobile/model/genre.dart'; 
import 'package:bookworm_mobile/providers/auth_provider.dart'; 

class ListDetailsScreen extends StatefulWidget {
  final ReadingList readingList;

  const ListDetailsScreen({Key? key, required this.readingList}) : super(key: key);

  @override
  State<ListDetailsScreen> createState() => _ListDetailsScreenState();
}

class _ListDetailsScreenState extends State<ListDetailsScreen> {
  ReadingList? _currentList;
  bool _isLoading = true;
  List<Genre> _genres = [];
  Genre? _selectedGenre;
  bool _isLoadingGenres = false;
  String? _selectedSort;
  bool _isPickingBook = false;
  ReadingListBook? _pickedBook;
  int _currentPickIndex = 0;
  Timer? _pickAnimationTimer;

  @override
  void initState() {
    super.initState();
    _loadListDetails();
    _loadGenres();
  }

  bool _canEditList() {
    final username = AuthProvider.username;
    if (username == null) return false;
    
  
    final list = _currentList ?? widget.readingList;
   
    return list.userName == username;
  }

  Future<void> _loadListDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ReadingListProvider>(context, listen: false);
      final updatedList = await provider.getById(widget.readingList.id);
     
      ReadingList? filteredList;
      if (updatedList != null) {
        if (_canEditList()) {
        
          filteredList = updatedList;
        } else {
          List<ReadingListBook> approvedBooks = [];
          for (var book in updatedList.books) {
            try {
              final bookProvider = BookProvider();
              final fullBook = await bookProvider.getById(book.bookId);
              
              if (fullBook.bookState == 'Accepted') {
                approvedBooks.add(book);
              }
            } catch (e) {
              print('Error fetching book details for filtering: $e');
           
            }
          }
        
          filteredList = ReadingList(
            id: updatedList.id,
            userId: updatedList.userId,
            userName: updatedList.userName,
            name: updatedList.name,
            description: updatedList.description,
            isPublic: updatedList.isPublic,
            createdAt: updatedList.createdAt,
            coverImagePath: updatedList.coverImagePath,
            books: approvedBooks,
          );
        }
      }
      
      setState(() {
        _currentList = filteredList ?? widget.readingList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentList = widget.readingList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _currentList ?? widget.readingList;
    
    return Stack(
      children: [
        Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8D6748),
        foregroundColor: Colors.white,
        elevation: 2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              list.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${list.bookCount} books',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          if (_canEditList())
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        backgroundColor: Color(0xFF8D6748),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        title: Text('Search Books'),
                      ),
                      body: Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 40), 
                        child: SearchScreen(
                          preselectedListId: list.id,
                          onBookAdded: () {
                           
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ),
                    ),
                  ),
                );
                
              
                if (result == true) {
                  _loadListDetails();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
              onRefresh: _loadListDetails,
              child: Column(
                children: [
               
                  if (list.description.isNotEmpty)
                    Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFF8E1),
                            Color(0xFFFFF3E0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFF8D6748).withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: Color(0xFF8D6748),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'About this list',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8D6748),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            list.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _buildFilterButton('Genre', Icons.keyboard_arrow_down, isGenreButton: true),
                              SizedBox(width: 12),
                              _buildFilterButton('Sort', Icons.keyboard_arrow_down, isGenreButton: false, isSortButton: true),
                              SizedBox(width: 12),
                              _buildFilterButton('Pick for me', null, isGenreButton: false, isSortButton: false),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          
                  Expanded(
                    child: (_selectedGenre != null || _requiresFullBookDetails())
                        ? FutureBuilder<List<ReadingListBook>>(
                            future: _getFilteredBooksWithGenre(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(color: Color(0xFF8D6748)),
                                      SizedBox(height: 16),
                                      Text(
                                        _selectedGenre != null ? 'Filtering books...' : 'Sorting books...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF8D6748),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              final filteredBooks = snapshot.data ?? [];
                              
                              if (filteredBooks.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.book_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        _selectedGenre != null 
                                          ? 'No books in this genre'
                                          : 'No books to display',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        _selectedGenre != null
                                          ? 'Try selecting a different genre'
                                          : 'Try different sorting options',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              return ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: filteredBooks.length,
                                itemBuilder: (context, index) {
                                  final book = filteredBooks[index];
                                  return _buildBookItem(book, list);
                                },
                              );
                            },
                          )
                        : _getFilteredBooks().isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.book_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No books in this list yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Add some books to get started!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: _getFilteredBooks().length,
                                itemBuilder: (context, index) {
                                  final book = _getFilteredBooks()[index];
                                  return _buildBookItem(book, list);
                                },
                              ),
                  ),
                ],
              ),
        ),
       ),
        if (_isPickingBook || _pickedBook != null)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                margin: EdgeInsets.all(32),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                   
                    Text(
                      _isPickingBook ? 'Choosing a book for you...' : 'We have chosen a book for you',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    
                    if (_pickedBook != null)
                      GestureDetector(
                        onTap: () async {
                         
                          try {
                            final bookProvider = BookProvider();
                            final fullBook = await bookProvider.getById(_pickedBook!.bookId);
                            
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetailsScreen(book: fullBook),
                              ),
                            );
                            
                           
                            if (result == true) {
                              _loadListDetails();
                            }
                          } catch (e) {
                            print('Error fetching book details: $e');
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Error loading book details'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                          }
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          child: Container(
                            width: 120,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _pickedBook!.coverImagePath != null
                                  ? Image.network(
                                      _buildImageUrl(_pickedBook!.coverImagePath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Color(0xFF8D6748),
                                          child: Icon(
                                            Icons.book,
                                            color: Colors.white,
                                            size: 48,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Color(0xFF8D6748),
                                      child: Icon(
                                        Icons.book,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 16),
                    
                    if (_pickedBook != null)
                      Text(
                        _pickedBook!.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                   
                    if (_pickedBook != null)
                      FutureBuilder<Book?>(
                        future: BookProvider().getById(_pickedBook!.bookId),
                        builder: (context, AsyncSnapshot<Book?> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox(height: 20);
                          }
                          
                          final book = snapshot.data;
                          if (book != null) {
                            return Text(
                              book.authorName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8D6748),
                                decoration: TextDecoration.none,
                              ),
                              textAlign: TextAlign.center,
                            );
                          }
                          
                          return SizedBox.shrink();
                        },
                      ),
                    
                    SizedBox(height: 24),
                    
                  
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isPickingBook = false;
                              _pickedBook = null;
                            });
                            _pickAnimationTimer?.cancel();
                          },
                          child: const Text(
                            'Close',
                            style: const TextStyle(
                              color: Color(0xFF8D6748),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        if (!_isPickingBook && _pickedBook != null)
                          ElevatedButton(
                            onPressed: () {
                          
                              setState(() {
                                _isPickingBook = true;
                                _pickedBook = null;
                              });
                              _startPickAnimation();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8D6748),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Try Again',
                                                          style:  TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterButton(String text, IconData? icon, {required bool isGenreButton, bool isSortButton = false}) {
    return GestureDetector(
      onTap: () {
        if (isGenreButton) {
          _showGenreFilterDialog();
        } else if (isSortButton) {
          _showSortDialog();
        } else if (text == 'Pick for me') {
          _showPickForMeDialog();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: (isGenreButton && _selectedGenre != null) || (isSortButton && _selectedSort != null) 
            ? Color(0xFF5D4037) 
            : Color(0xFF8D6748),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                isGenreButton && _selectedGenre != null 
                  ? _selectedGenre!.name 
                  : isSortButton && _selectedSort != null
                    ? _getSortDisplayText(_selectedSort!)
                    : text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (icon != null) ...[
              SizedBox(width: 4),
              Icon(icon, color: Colors.white, size: 16),
            ],
          ],
        ),
      ),
    );
  }

  void _showGenreFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter by Genre'),
        content: Container(
          width: double.maxFinite,
          height: 300, 
          child: _isLoadingGenres
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _genres.map((genre) => ListTile(
                      title: Text(genre.name),
                      trailing: _selectedGenre?.id == genre.id 
                        ? Icon(Icons.check, color: Color(0xFF8D6748))
                        : null,
                      onTap: () {
                        setState(() {
                          _selectedGenre = _selectedGenre?.id == genre.id ? null : genre;
                        });
                        Navigator.of(context).pop();
                      },
                    )).toList(),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedGenre = null;
              });
              Navigator.of(context).pop();
            },
            child: Text('Clear Filter'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(ReadingListBook book, ReadingList list) {
    String? imageUrl;
    if (book.coverImagePath != null && book.coverImagePath!.isNotEmpty) {
      imageUrl = _buildImageUrl(book.coverImagePath!);
    }
    
    return GestureDetector(
      onTap: () async {
       
        try {
          final bookProvider = BookProvider();
          final bookObj = await bookProvider.getById(book.bookId);
          
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailsScreen(book: bookObj),
            ),
          );
         
          if (result == true) {
            _loadListDetails();
          }
        } catch (e) {
        
          final bookObj = Book(
            id: book.bookId,
            title: book.title,
            authorId: 0,
            authorName: '',
            description: '',
            publicationYear: 0,
            pageCount: 0,
            bookState: '',
            genres: [],
            coverImagePath: book.coverImagePath,
          );
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailsScreen(book: bookObj),
            ),
          );
          
          if (result == true) {
            _loadListDetails();
          }
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(12),
          leading: Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultBookCover(),
                    )
                  : _buildDefaultBookCover(),
            ),
          ),
          title: Text(
            book.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4E342E),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                'Added on ${_formatDate(book.addedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              FutureBuilder<Map<String, dynamic>?>(
                future: _getBookRating(book.bookId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Row(
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
                          style: TextStyle(fontSize: 12, color: Color(0xFF8D6748)),
                        ),
                      ],
                    );
                  }
                  if (snapshot.hasError) {
                    return Row(
                      children: [
                        Icon(Icons.star_border, color: Color(0xFFFFD700), size: 16),
                        SizedBox(width: 8),
                        Text('No ratings', style: TextStyle(fontSize: 12, color: Color(0xFF8D6748))),
                      ],
                    );
                  }
                  final ratingData = snapshot.data;
                  if (ratingData == null || ratingData['ratingCount'] == 0) {
                    return Row(
                      children: [
                        Icon(Icons.star_border, color: Color(0xFFFFD700), size: 16),
                        SizedBox(width: 8),
                        Text('No ratings', style: TextStyle(fontSize: 12, color: Color(0xFF8D6748))),
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
                            return Icon(Icons.star, color: Color(0xFFFFD700), size: 16);
                          } else if (index == averageRating.floor() && averageRating % 1 > 0) {
                            return Icon(Icons.star_half, color: Color(0xFFFFD700), size: 16);
                          } else {
                            return Icon(Icons.star_border, color: Color(0xFFFFD700), size: 16);
                          }
                        }),
                      ),
                      SizedBox(width: 8),
                      Text('${ratingCount} Ratings', style: TextStyle(fontSize: 12, color: Color(0xFF8D6748))),
                    ],
                  );
                },
              ),
            ],
          ),
          trailing: _canEditList() ? PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Color(0xFF8D6E63)),
            onSelected: (value) => _handleBookAction(value, book, list),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.remove_circle, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Remove from List', style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ) : null,
        ),
      ),
    );
  }

  Widget _buildDefaultBookCover() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Color(0xFFD7CCC8),
      ),
      child: Icon(
        Icons.book,
        color: Color(0xFF8D6E63),
        size: 24,
      ),
    );
  }

  String _buildImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    } else {
      String base = BaseProvider.baseUrl ?? '';
      if (base.endsWith('/api/')) {
        base = base.substring(0, base.length - 5);
      }
      return '$base/$imagePath';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleBookAction(String action, ReadingListBook book, ReadingList list) {
    if (action == 'remove') {
      _removeBookFromList(book, list);
    }
  }

  Future<void> _removeBookFromList(ReadingListBook book, ReadingList list) async {
   
    if (!_canEditList()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only remove books from your own lists'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Book'),
        content: Text('Are you sure you want to remove "${book.title}" from this list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = Provider.of<ReadingListProvider>(context, listen: false);
        final updatedList = await provider.removeBookFromList(list.id, book.bookId);
        
        if (updatedList != null) {
          setState(() {
            _currentList = updatedList;
          });
                  ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book removed from list'),
            backgroundColor: Colors.green,
          ),
        );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove book'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      return null;
    }
  }

  Future<void> _loadGenres() async {
    setState(() {
      _isLoadingGenres = true;
    });

    try {
      final provider = GenreProvider();
      final genres = await provider.getAllGenres();
      setState(() {
        _genres = genres;
        _isLoadingGenres = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGenres = false;
      });
    }
  }

  List<ReadingListBook> _getFilteredBooks() {
    if (_currentList == null) return [];
    
    List<ReadingListBook> books = _currentList!.books;
    
    if (_selectedSort != null) {
      books = _sortBooks(books);
    }
    
    return books;
  }

  List<ReadingListBook> _sortBooks(List<ReadingListBook> books) {
    switch (_selectedSort) {
      case 'title_asc':
        books.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'title_desc':
        books.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'added_desc':
        books.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
      case 'added_asc':
        books.sort((a, b) => a.addedAt.compareTo(b.addedAt));
        break;
      
    }
    
    return books;
  }

  Future<List<ReadingListBook>> _getFilteredBooksWithGenre() async {
    if (_currentList == null) return [];
    
    List<ReadingListBook> books = _currentList!.books;
    
    if (_selectedGenre != null || _requiresFullBookDetails()) {
      List<ReadingListBook> filteredBooks = [];
      
      for (ReadingListBook book in books) {
        try {
          final bookProvider = BookProvider();
          final fullBook = await bookProvider.getById(book.bookId);
         
          if (_selectedGenre != null) {
            if (!fullBook.genres.contains(_selectedGenre!.name)) {
              continue; 
            }
          }
          
          filteredBooks.add(book);
        } catch (e) {
        
          filteredBooks.add(book);
        }
      }
      
      if (_requiresFullBookDetails()) {
        filteredBooks = await _sortBooksWithFullDetails(filteredBooks);
      }
      
      return filteredBooks;
    }
    
    return books;
  }

  bool _requiresFullBookDetails() {
    return _selectedSort == 'rating_desc' || 
           _selectedSort == 'rating_asc' || 
           _selectedSort == 'year_desc' || 
           _selectedSort == 'year_asc';
  }

  Future<List<ReadingListBook>> _sortBooksWithFullDetails(List<ReadingListBook> books) async {
    List<Map<String, dynamic>> booksWithDetails = [];
    
    for (ReadingListBook book in books) {
      try {
        final bookProvider = BookProvider();
        final fullBook = await bookProvider.getById(book.bookId);
        
        final ratingData = await _getBookRating(book.bookId);
        final averageRating = ratingData?['averageRating'] ?? 0.0;
        
        booksWithDetails.add({
          'book': book,
          'fullBook': fullBook,
          'rating': averageRating,
        });
      } catch (e) {
        booksWithDetails.add({
          'book': book,
          'fullBook': null,
          'rating': 0.0,
        });
      }
    }
    
    switch (_selectedSort) {
      case 'rating_desc':
        booksWithDetails.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
        break;
      case 'rating_asc':
        booksWithDetails.sort((a, b) => (a['rating'] as double).compareTo(b['rating'] as double));
        break;
      case 'year_desc':
        booksWithDetails.sort((a, b) => (b['fullBook']?.publicationYear ?? 0).compareTo(a['fullBook']?.publicationYear ?? 0));
        break;
      case 'year_asc':
        booksWithDetails.sort((a, b) => (a['fullBook']?.publicationYear ?? 0).compareTo(b['fullBook']?.publicationYear ?? 0));
        break;
    }
   
    return booksWithDetails.map((item) => item['book'] as ReadingListBook).toList();
  }

  void _showPickForMeDialog() {
    if (_currentList == null || _currentList!.books.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No books in this list to pick from!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isPickingBook = true;
      _pickedBook = null;
      _currentPickIndex = 0;
    });

    _startPickAnimation();
  }

  void _startPickAnimation() {
    final books = _getFilteredBooks();
    if (books.isEmpty) return;

    _pickAnimationTimer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      setState(() {
       
        _currentPickIndex = (DateTime.now().millisecondsSinceEpoch % books.length);
        _pickedBook = books[_currentPickIndex];
      });

      if (timer.tick >= 20) {
        timer.cancel();
        _finalizePick();
      }
    });
  }

  void _finalizePick() {
    setState(() {
      _isPickingBook = false;
    });
    _pickAnimationTimer?.cancel();
  }

  @override
  void dispose() {
    _pickAnimationTimer?.cancel();
    super.dispose();
  }

  String _getSortDisplayText(String sortType) {
    switch (sortType) {
      case 'rating_desc':
        return 'Rating ↓';
      case 'rating_asc':
        return 'Rating ↑';
      case 'title_asc':
        return 'Title A-Z';
      case 'title_desc':
        return 'Title Z-A';
      case 'year_desc':
        return 'Year ↓';
      case 'year_asc':
        return 'Year ↑';
      case 'added_desc':
        return 'Added ↓';
      case 'added_asc':
        return 'Added ↑';
      default:
        return 'Sort';
    }
  }

  void _showSortDialog() {
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
                    },
                  ),
                  ListTile(
                    title: const Text('Rating (High to Low)'),
                    onTap: () {
                      setState(() => _selectedSort = 'rating_desc');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Rating (Low to High)'),
                    onTap: () {
                      setState(() => _selectedSort = 'rating_asc');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Title (A-Z)'),
                    onTap: () {
                      setState(() => _selectedSort = 'title_asc');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Title (Z-A)'),
                    onTap: () {
                      setState(() => _selectedSort = 'title_desc');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Publication Year (Newest)'),
                    onTap: () {
                      setState(() => _selectedSort = 'year_desc');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Publication Year (Oldest)'),
                    onTap: () {
                      setState(() => _selectedSort = 'year_asc');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Added Date (Newest)'),
                    onTap: () {
                      setState(() => _selectedSort = 'added_desc');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Added Date (Oldest)'),
                    onTap: () {
                      setState(() => _selectedSort = 'added_asc');
                      Navigator.pop(context);
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
} 