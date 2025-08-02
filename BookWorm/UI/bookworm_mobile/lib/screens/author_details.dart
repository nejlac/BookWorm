import 'package:flutter/material.dart';
import '../model/author.dart';
import '../model/book.dart';
import '../providers/book_provider.dart';
import '../providers/base_provider.dart';
import 'book_details.dart';

class AuthorDetailsScreen extends StatefulWidget {
  final Author author;

  const AuthorDetailsScreen({Key? key, required this.author}) : super(key: key);

  @override
  State<AuthorDetailsScreen> createState() => _AuthorDetailsScreenState();
}

class _AuthorDetailsScreenState extends State<AuthorDetailsScreen> {

  final BookProvider _bookProvider = BookProvider();
  Author? _authorWithBooks;
  List<Book> _booksWithCovers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAuthorWithBooks();
  }

  Future<void> _loadAuthorWithBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load books by author using BookProvider
      final filter = <String, dynamic>{
        'pageSize': 50,
        'page': 0,
        'authorId': widget.author.id,
      };

      final result = await _bookProvider.get(filter: filter);
      
      setState(() {
        _authorWithBooks = widget.author;
        _booksWithCovers = result.items ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getAuthorImageUrl() {
    final author = widget.author;
    final hasImage = author.photoUrl != null && author.photoUrl!.isNotEmpty;
    if (!hasImage) return '';
    
    if (author.photoUrl!.startsWith('http')) {
      return author.photoUrl!;
    } else {
      String base = BaseProvider.baseUrl ?? '';
      if (base.endsWith('/api/')) {
        base = base.substring(0, base.length - 5);
      }
      return '$base/${author.photoUrl}';
    }
  }



  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }



  @override
  Widget build(BuildContext context) {
    final imageUrl = _getAuthorImageUrl();
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero-style app bar with author image as background
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF8D6748),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Author image as background with overlay
                  if (imageUrl.isNotEmpty)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF8D6748),
                                const Color(0xFF5D4037),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 100,
                            color: Colors.white54,
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF8D6748),
                            const Color(0xFF5D4037),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.white54,
                      ),
                    ),
                  // Gradient overlay for better text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Author name positioned at bottom
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.author.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.author.countryName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Author information section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Books',
                          _booksWithCovers.length.toString(),
                          Icons.book,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'Born',
                          _formatDate(widget.author.dateOfBirth),
                          Icons.calendar_today,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Biography section
                  if (widget.author.biography.isNotEmpty) ...[
                    const Text(
                      'Biography',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0C9A6)),
                      ),
                      child: Text(
                        widget.author.biography,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF5D4037),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Books section
                  Row(
                    children: [
                      const Icon(
                        Icons.library_books,
                        color: Color(0xFF8D6748),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Books by this Author',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Books list
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF8D6748),
                  ),
                ),
              ),
            )
          else if (_errorMessage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error,
                        color: Color(0xFF8D6748),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading author: $_errorMessage',
                        style: const TextStyle(color: Color(0xFF8D6748)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_booksWithCovers.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.book_outlined,
                        color: Color(0xFF8D6748),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No books found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This author hasn\'t published any books yet',
                        style: TextStyle(color: Color(0xFF8D6748)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final book = _booksWithCovers[index];
                  return _buildBookCard(book);
                },
                childCount: _booksWithCovers.length,
              ),
            ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0C9A6)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF8D6748),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8D6748),
            ),
          ),
        ],
      ),
    );
  }

  String _getBookCoverImageUrl(Book book) {
    final hasImage = book.coverImagePath != null && book.coverImagePath!.isNotEmpty;
    if (!hasImage) return '';
    
    if (book.coverImagePath!.startsWith('http')) {
      return book.coverImagePath!;
    } else {
      String base = BaseProvider.baseUrl ?? '';
      if (base.endsWith('/api/')) {
        base = base.substring(0, base.length - 5);
      }
      return '$base/${book.coverImagePath}';
    }
  }

  Widget _buildBookCard(Book book) {
    final coverUrl = _getBookCoverImageUrl(book);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(book: book),
          ),
        );
      },
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0C9A6)),
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Book cover
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: coverUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0C9A6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.book,
                              color: Color(0xFF8D6748),
                              size: 40,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0C9A6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.book,
                        color: Color(0xFF8D6748),
                        size: 40,
                      ),
                    ),
            ),
            
            const SizedBox(width: 16),
            
            // Book details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Publication year
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFF8D6748),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${book.publicationYear}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8D6748),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Page count
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book,
                        size: 16,
                        color: Color(0xFF8D6748),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${book.pageCount} pages',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8D6748),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Genres
                  if (book.genres.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: book.genres.take(3).map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8D6748),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            genre,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
} 