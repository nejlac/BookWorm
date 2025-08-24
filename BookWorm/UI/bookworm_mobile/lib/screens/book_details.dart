import 'package:bookworm_mobile/providers/auth_provider.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/author_provider.dart';
import '../providers/bookReview_provider.dart';
import '../providers/user_provider.dart';
import '../providers/quote_provider.dart';
import '../providers/reading_list_provider.dart';
import '../model/book.dart';
import '../model/author.dart';
import '../model/bookReview.dart';
import '../model/user.dart';
import '../model/quote.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;
  final int? preselectedListId; 

  const BookDetailsScreen({Key? key, required this.book, this.preselectedListId}) : super(key: key);

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double? _averageRating;
  int? _ratingCount;
  Author? _author;
  bool _isLoadingAuthor = false;
  List<BookReview> _reviews = [];
  Map<int, User> _users = {};
  bool _isLoadingReviews = false;
  List<Quote> _quotes = [];
  Map<int, User> _quoteUsers = {};
  bool _isLoadingQuotes = false;
  
  
  int _selectedRating = 0;
  final TextEditingController _reviewTextController = TextEditingController();
  bool _isSubmittingReview = false;
  bool _isLoadingUserReview = false;
  BookReview? _userReview; 
  final TextEditingController _quoteTextController = TextEditingController();
  bool _isSubmittingQuote = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadBookRating();
    _loadAuthor();
    _loadReviews();
    _loadQuotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewTextController.dispose();
    _quoteTextController.dispose();
    super.dispose();
  }

  Future<void> _loadBookRating() async {
    try {
      final url = '${BaseProvider.baseUrl ?? "http://10.0.2.2:7031/api/"}book/${widget.book.id}/rating';
      final uri = Uri.parse(url);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _averageRating = data['averageRating']?.toDouble() ?? 0.0;
          _ratingCount = data['ratingCount'] ?? 0;
        });
      } else {
        print('Failed to load rating: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading book rating: $e');
    }
  }

  Future<void> _loadAuthor() async {
    try {
      setState(() {
        _isLoadingAuthor = true;
      });
      
      final authorProvider = Provider.of<AuthorProvider>(context, listen: false);
      final author = await authorProvider.getById(widget.book.authorId);
      
      setState(() {
        _author = author;
        _isLoadingAuthor = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAuthor = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    try {
      setState(() {
        _isLoadingReviews = true;
        _isLoadingUserReview = true;
      });
      
      final reviewProvider = Provider.of<BookReviewProvider>(context, listen: false);
      final filter = {
        'bookId': widget.book.id,
        'pageSize': 1000, 
        'page': 0,
      };
      final result = await reviewProvider.get(filter: filter);
     
      
      final reviews = result.items ?? [];
      
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
      
      
      await _loadUsersForReviews(reviews);
    } catch (e) {
      setState(() {
        _isLoadingReviews = false;
        _isLoadingUserReview = false;
      });
    }
  }

  Future<void> _loadUsersForReviews(List<BookReview> reviews) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final users = <int, User>{};
      
      for (final review in reviews) {
        try {
          final user = await userProvider.getById(review.userId);
          users[review.userId] = user;
        } catch (e) {
          print('Error loading user ${review.userId}: $e');
        }
      }
      
      setState(() {
        _users = users;
      });
      
      // Now that users are loaded, find the current user's review
      final currentUsername = AuthProvider.username;
      if (currentUsername != null) {
        _reviews.sort((a, b) {
          final userA = _users[a.userId];
          final userB = _users[b.userId];
          final isUserA = userA?.username == currentUsername;
          final isUserB = userB?.username == currentUsername;
          
          if (isUserA && !isUserB) return -1;
          if (!isUserA && isUserB) return 1;
          
          return b.createdAt.compareTo(a.createdAt);
        });
        
        try {
          _userReview = _reviews.firstWhere(
            (review) {
              final user = _users[review.userId];
              return user?.username == currentUsername;
            },
            orElse: () => null as BookReview,
          );
        } catch (e) {
          _userReview = null;
        }
      }
      
      setState(() {
        _isLoadingUserReview = false;
      });
    } catch (e) {
      print('Error loading users for reviews: $e');
      setState(() {
        _isLoadingUserReview = false;
      });
    }
  }

  Future<void> _loadQuotes() async {
    try {
      setState(() {
        _isLoadingQuotes = true;
      });
      
      final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
      final filter = {
        'bookId': widget.book.id,
        'pageSize': 1000, 
        'page': 0,
      };
      
      final result = await quoteProvider.get(filter: filter);
      
      final quotes = result.items ?? [];
      
      setState(() {
        _quotes = quotes;
        _isLoadingQuotes = false;
      });
      
      
      await _loadUsersForQuotes(quotes);
    } catch (e) {
      setState(() {
        _isLoadingQuotes = false;
      });
    }
  }

  Future<void> _loadUsersForQuotes(List<Quote> quotes) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final users = <int, User>{};
      
      for (final quote in quotes) {
        if (quote.userId != null) {
          try {
            final user = await userProvider.getById(quote.userId!);
            users[quote.userId!] = user;
          } catch (e) {
            print('Error loading user ${quote.userId}: $e');
          }
        }
      }
      
      setState(() {
        _quoteUsers = users;
      });
    } catch (e) {
      print('Error loading users for quotes: $e');
    }
  }

  String _getBookCoverImageUrl(String? coverImagePath) {
    if (coverImagePath == null || coverImagePath.isEmpty) {
      return '';
    }
    
    if (coverImagePath.startsWith('http')) {
      return coverImagePath;
    } else {
      String base = BaseProvider.baseUrl ?? '';
      if (base.endsWith('/api/')) {
        base = base.substring(0, base.length - 5);
      }
      return '$base/${coverImagePath}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8D6748)),
          onPressed: () {
            Navigator.pop(context, true); // Return true to indicate refresh needed
          },
        ),
        title: const Text(
          'Details',
          style: TextStyle(
            color: Color(0xFF8D6748),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
          
            Container(
              margin: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _getBookCoverImageUrl(widget.book.coverImagePath).isNotEmpty
                    ? Image.network(
                        _getBookCoverImageUrl(widget.book.coverImagePath),
                        width: 200,
                        height: 280,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 280,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0C9A6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.book,
                              size: 80,
                              color: Color(0xFF8D6748),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 200,
                        height: 280,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0C9A6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.book,
                          size: 80,
                          color: Color(0xFF8D6748),
                        ),
                      ),
              ),
            ),

         
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    widget.book.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.book.authorName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8D6748),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

          
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    if (_averageRating != null) {
                      if (index < _averageRating!.floor()) {
                        return const Icon(Icons.star, color: Color(0xFFFFD700), size: 20);
                      } else if (index == _averageRating!.floor() && _averageRating! % 1 > 0) {
                        return const Icon(Icons.star_half, color: Color(0xFFFFD700), size: 20);
                      } else {
                        return const Icon(Icons.star_border, color: Color(0xFFFFD700), size: 20);
                      }
                    } else {
                      return const Icon(Icons.star_border, color: Color(0xFFFFD700), size: 20);
                    }
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  _averageRating != null && _ratingCount != null 
                      ? '$_averageRating ($_ratingCount reviews)'
                      : 'No ratings yet',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8D6748),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

        
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoadingUserReview ? null : () {
                        _handleRateButton();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8D6748),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoadingUserReview 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_userReview != null ? 'Edit Rating' : 'Rate'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAddToListDialog();
                      },
                      icon: const Icon(Icons.bookmark_add, size: 18),
                      label: const Text('Add To List'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8D6748),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0C9A6)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF8D6748),
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF8D6748),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                indicatorSize: TabBarIndicatorSize.tab,
                tabAlignment: TabAlignment.fill,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                tabs: const [
                  Tab(text: 'Summary', height: 50),
                  Tab(text: 'About', height: 50),
                  Tab(text: 'Author', height: 50),
                  Tab(text: 'Reviews', height: 50),
                  Tab(text: 'Quotes', height: 50),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Container(
              height: 400,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSummaryTab(),
                  _buildAboutTab(),
                  _buildAuthorTab(),
                  _buildReviewsTab(),
                  _buildQuotesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      child: Text(
        widget.book.description ?? 'No summary available for this book.',
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF5D4037),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          const SizedBox(height: 16),
          _buildInfoRow('Publication Year', widget.book.publicationYear.toString()),
          _buildInfoRow('Pages', widget.book.pageCount.toString()),
          _buildInfoRow('Genre', widget.book.genres.join(', ')),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8D6748),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildAuthorTab() {
    if (_isLoadingAuthor) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8D6748),
        ),
      );
    }

    if (_author == null) {
      return const Center(
        child: Text(
          'Author information not available',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF8D6748),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            _author!.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 16),
          if (_author!.dateOfBirth != null) ...[
            _buildInfoRow('Date of Birth', _formatDate(_author!.dateOfBirth!)),
            const SizedBox(height: 16),
          ],
          if (_author!.biography.isNotEmpty) ...[
            const Text(
              'Biography',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _author!.biography,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5D4037),
                height: 1.5,
              ),
            ),
          ] else ...[
            const Text(
              'Biography not available for this author.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8D6748),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks} week${weeks > 1 ? 's' : ''} ago';
      } else {
        final months = (difference.inDays / 30).floor();
        return '${months} month${months > 1 ? 's' : ''} ago';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String _getUserImageUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return '';
    }
    
    if (photoUrl.startsWith('http')) {
      return photoUrl;
    } else {
      String base = BaseProvider.baseUrl ?? '';
      if (base.endsWith('/api/')) {
        base = base.substring(0, base.length - 5);
      }
      return '$base/${photoUrl}';
    }
  }

  Widget _buildReviewsTab() {
    if (_isLoadingReviews) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8D6748),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          
          Container(
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_userReview != null) {
                  _showAlreadyReviewedMessage();
                } else {
                  _showAddReviewDialog();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0C9A6),
                foregroundColor: const Color(0xFF5D4037),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add your review',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

      
          if (_reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review,
                    size: 64,
                    color: Color(0xFF8D6748),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No reviews yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Be the first to review this book!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8D6748),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._reviews.map((review) => _buildReviewCard(review)).toList(),
           const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BookReview review) {
    final user = _users[review.userId];
    final userName = user?.firstName != null && user?.lastName != null
        ? '${user!.firstName} ${user.lastName}'
        : review.userName;
    final userImageUrl = _getUserImageUrl(user?.photoUrl);
    final currentUsername = AuthProvider.username;
    final isCurrentUserReview = currentUsername != null && user?.username == currentUsername;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE0C9A6),
                  backgroundImage: userImageUrl.isNotEmpty
                      ? NetworkImage(userImageUrl)
                      : null,
                  child: userImageUrl.isEmpty
                      ? Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Color(0xFF8D6748),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
            
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      Text(
                        _formatTimeAgo(review.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8D6748),
                        ),
                      ),
                    ],
                  ),
                ),
                
               
                if (isCurrentUserReview)
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showEditReviewDialog(review),
                        icon: const Icon(
                          Icons.edit,
                          color: Color(0xFF8D6748),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      IconButton(
                        onPressed: () => _showDeleteReviewDialog(review),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: List.generate(5, (index) {
                if (index < review.rating) {
                  return const Icon(
                    Icons.star,
                    color: Color(0xFFFFD700),
                    size: 20,
                  );
                } else {
                  return const Icon(
                    Icons.star_border,
                    color: Color(0xFFFFD700),
                    size: 20,
                  );
                }
              }),
            ),
            
            const SizedBox(height: 12),
          
            if (review.review != null && review.review!.isNotEmpty)
              Text(
                review.review!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5D4037),
                  height: 1.5,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotesTab() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isSubmittingQuote ? null : _showAddQuoteDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE0C9A6),
              foregroundColor: const Color(0xFF5D4037),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmittingQuote
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF5D4037),
                    ),
                  )
                : const Text(
                    'Add a quote',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),

      
        if (_isLoadingQuotes)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8D6748),
              ),
            ),
          )
        else if (_quotes.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'No quotes yet for this book.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8D6748),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quotes.length,
              itemBuilder: (context, index) {
                final quote = _quotes[index];
                return _buildQuoteCard(quote);
                
              },
            ),
          ),
          const SizedBox(height: 30),
      ],
    );
  }

  void _showAddReviewDialog() {
    // Double-check that user doesn't already have a review
    if (_userReview != null) {
      _showEditReviewDialog(_userReview!);
      return;
    }
    
    _selectedRating = 0;
    _reviewTextController.clear();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
        backgroundColor: const Color(0xFFFFF8E1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
            children: [
             
              Row(
                children: [
                  const Icon(
                    Icons.rate_review,
                    color: Color(0xFF8D6748),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Your Review',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF8D6748),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
             
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0C9A6)),
                ),
                child: Row(
                  children: [
                  
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: widget.book.coverImagePath != null && widget.book.coverImagePath!.isNotEmpty
                          ? Image.network(
                              _getBookCoverImageUrl(widget.book.coverImagePath),
                              width: 60,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0C9A6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.book,
                                    size: 30,
                                    color: Color(0xFF8D6748),
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 60,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0C9A6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.book,
                                size: 30,
                                color: Color(0xFF8D6748),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.book.title,
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
                            widget.book.authorName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8D6748),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
           
              const Text(
                'Rate this book',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5D4037),
                ),
              ),
              const SizedBox(height: 12),
              
          
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        _selectedRating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < _selectedRating ? Icons.star : Icons.star_border,
                        color: const Color(0xFFFFD700),
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 8),
              Text(
                _selectedRating == 0 
                    ? 'Tap to rate'
                    : '$_selectedRating ${_selectedRating == 1 ? 'star' : 'stars'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8D6748),
                ),
              ),
              
              const SizedBox(height: 24),
              
           
              const Text(
                'Write your review (optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5D4037),
                ),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: _reviewTextController,
                maxLines: 4,
                maxLength: 2000,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts about this book...',
                  hintStyle: const TextStyle(color: Color(0xFF8D6748)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0C9A6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8D6748), width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              
              const SizedBox(height: 24),
              
            
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF8D6748),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                                          child: ElevatedButton(
                        onPressed: _selectedRating == 0 || _isSubmittingReview
                            ? null
                            : () => _submitReview(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8D6748),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmittingReview
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Submit Review',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),));
  }

  void _showEditReviewDialog(BookReview review) {
    _selectedRating = review.rating;
    _reviewTextController.text = review.review ?? '';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: const Color(0xFFFFF8E1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
               
                  Row(
                    children: [
                      const Icon(
                        Icons.edit,
                        color: Color(0xFF8D6748),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Edit Your Review',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF8D6748),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
               
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0C9A6)),
                    ),
                    child: Row(
                      children: [
                    
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widget.book.coverImagePath != null && widget.book.coverImagePath!.isNotEmpty
                              ? Image.network(
                                  _getBookCoverImageUrl(widget.book.coverImagePath),
                                  width: 60,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0C9A6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.book,
                                        size: 30,
                                        color: Color(0xFF8D6748),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: 60,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0C9A6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.book,
                                    size: 30,
                                    color: Color(0xFF8D6748),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.book.title,
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
                                widget.book.authorName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8D6748),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
           
                  const Text(
                    'Rate this book',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 12),
             
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            _selectedRating = index + 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < _selectedRating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFFD700),
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 8),
                  Text(
                    _selectedRating == 0 
                        ? 'Tap to rate'
                        : '$_selectedRating ${_selectedRating == 1 ? 'star' : 'stars'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8D6748),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                
                  const Text(
                    'Write your review (optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: _reviewTextController,
                    maxLines: 4,
                    maxLength: 2000,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts about this book...',
                      hintStyle: const TextStyle(color: Color(0xFF8D6748)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0C9A6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF8D6748), width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
           
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF8D6748),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedRating == 0 || _isSubmittingReview
                              ? null
                              : () => _updateReview(dialogContext, review),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8D6748),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmittingReview
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Update Review',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
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
      ),
    );
  }

  void _showDeleteReviewDialog(BookReview review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8E1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete Review',
          style: TextStyle(
            color: Color(0xFF5D4037),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete your review? This action cannot be undone.',
          style: TextStyle(
            color: Color(0xFF5D4037),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8D6748)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteReview(review);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateReview(BuildContext dialogContext, BookReview review) async {
  
    final ratingError = _validateRating(_selectedRating);
    if (ratingError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ratingError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    final reviewText = _reviewTextController.text.trim();
    final reviewError = _validateReviewText(reviewText.isEmpty ? null : reviewText);
    if (reviewError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reviewError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmittingReview = true;
    });
    
    try {
      final reviewProvider = Provider.of<BookReviewProvider>(context, listen: false);
      
   
      final request = {
        'userId': review.userId,
        'bookId': review.bookId,
        'rating': _selectedRating,
        'review': _reviewTextController.text.trim().isEmpty 
            ? null 
            : _reviewTextController.text.trim(),
        'isChecked': review.isChecked,
      };
      
      
      await reviewProvider.update(review.id, request);
      
 
      Navigator.of(dialogContext).pop();
      
 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Review updated successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF8D6748),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      
   
      await _loadReviews();
      await _loadBookRating();
      
 
      final currentUsername = AuthProvider.username;
      if (currentUsername != null) {
        _userReview = _reviews.firstWhere(
          (review) {
            final user = _users[review.userId];
            return user?.username == currentUsername;
          },
          orElse: () => null as BookReview,
        );
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating review: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() {
        _isSubmittingReview = false;
      });
    }
  }

  void _handleRateButton() {
    if (_isLoadingUserReview) {
      return; // Prevent action while loading
    }
    
    if (_userReview != null) {
      _showEditReviewDialog(_userReview!);
    } else {
      _showAddReviewDialog();
    }
  }

  void _showAlreadyReviewedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'You have already reviewed this book. You can only leave one review per book.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8D6748),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Edit',
          textColor: Colors.white,
          onPressed: () {
            if (_userReview != null) {
              _showEditReviewDialog(_userReview!);
            }
          },
        ),
      ),
    );
  }

  String? _validateReviewText(String? text) {
    if (text == null || text.trim().isEmpty) {
      return null; 
    }
    
    if (text.trim().length > 2000) {
      return 'Review text cannot exceed 2000 characters';
    }
    
    return null;
  }

  String? _validateRating(int rating) {
    if (rating < 1 || rating > 5) {
      return 'Rating must be between 1 and 5';
    }
    return null;
  }

  Future<void> _deleteReview(BookReview review) async {
    try {
      final reviewProvider = Provider.of<BookReviewProvider>(context, listen: false);
      
      
      await reviewProvider.delete(review.id);
      
  
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Review deleted successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF8D6748),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      
   
      await _loadReviews();
      await _loadBookRating();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting review: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _submitReview(BuildContext dialogContext) async {
  
    final ratingError = _validateRating(_selectedRating);
    if (ratingError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ratingError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    

    final reviewText = _reviewTextController.text.trim();
    final reviewError = _validateReviewText(reviewText.isEmpty ? null : reviewText);
    if (reviewError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reviewError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmittingReview = true;
    });
    
    try {
      final reviewProvider = Provider.of<BookReviewProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
     
      final username = AuthProvider.username;
      if (username == null) throw Exception('No user logged in');
      
      final userResult = await userProvider.get(filter: {'username': username, 'pageSize': 1});
      final user = userResult.items?.first;
      if (user == null) throw Exception('User not found');
      
  
      final request = {
        'userId': user.id,
        'bookId': widget.book.id,
        'rating': _selectedRating,
        'review': _reviewTextController.text.trim().isEmpty 
            ? null 
            : _reviewTextController.text.trim(),
        'isChecked': false,
      };
      
      
      await reviewProvider.insert(request);
      
     
      Navigator.of(dialogContext).pop();
      

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Review submitted successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF8D6748),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      
     
      await _loadReviews();
      await _loadBookRating();
      
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      String displayMessage;
      
      if (errorMessage.contains('already exists') || 
          errorMessage.contains('duplicate') || 
          errorMessage.contains('already reviewed') ||
          errorMessage.contains('user has already reviewed')) {
        displayMessage = 'You have already reviewed this book. You can only leave one review per book.';
        
        // Refresh the user review state to show the existing review
        await _loadReviews();
      } else {
        displayMessage = 'Error submitting review: ${e.toString()}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            displayMessage,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: errorMessage.contains('already exists') || 
                  errorMessage.contains('duplicate') || 
                  errorMessage.contains('already reviewed') ||
                  errorMessage.contains('user has already reviewed')
            ? SnackBarAction(
                label: 'Edit',
                textColor: Colors.white,
                onPressed: () {
                  if (_userReview != null) {
                    _showEditReviewDialog(_userReview!);
                  }
                },
              )
            : null,
        ),
      );
    } finally {
      setState(() {
        _isSubmittingReview = false;
      });
    }
  }

  Widget _buildQuoteCard(Quote quote) {
    final user = quote.userId != null ? _quoteUsers[quote.userId] : null;
    final currentUsername = AuthProvider.username;
    final isCurrentUserQuote = currentUsername != null && user?.username == currentUsername;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E3B4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0C9A6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          Text(
            quote.quoteText,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF5D4037),
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
          
          if (isCurrentUserQuote) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _showEditQuoteDialog(quote),
                  icon: const Icon(
                    Icons.edit,
                    size: 20,
                    color: Color(0xFF8D6748),
                  ),
                ),
                IconButton(
                  onPressed: () => _showDeleteQuoteDialog(quote),
                  icon: const Icon(
                    Icons.delete,
                    size: 20,
                    color: Color(0xFF8D6748),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showAddQuoteDialog() {
    _quoteTextController.clear();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: const Color(0xFFFFF8E1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
               
                  Row(
                    children: [
                      const Icon(
                        Icons.format_quote,
                        color: Color(0xFF8D6748),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Add a Quote',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF8D6748),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                 
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0C9A6)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widget.book.coverImagePath != null && widget.book.coverImagePath!.isNotEmpty
                              ? Image.network(
                                  _getBookCoverImageUrl(widget.book.coverImagePath),
                                  width: 60,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0C9A6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.book,
                                        size: 30,
                                        color: Color(0xFF8D6748),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: 60,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0C9A6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.book,
                                    size: 30,
                                    color: Color(0xFF8D6748),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.book.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.book.authorName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8D6748),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                
                  const Text(
                    'Share your favorite quote',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: _quoteTextController,
                    maxLines: 6,
                    maxLength: 10000,
                    decoration: InputDecoration(
                      hintText: 'Enter your favorite quote from this book...',
                      hintStyle: const TextStyle(color: Color(0xFF8D6748)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0C9A6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF8D6748), width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF8D6748),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmittingQuote ? null : () => _submitQuote(dialogContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8D6748),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmittingQuote
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Add Quote',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
      ),
    );
  }

  void _showEditQuoteDialog(Quote quote) {
    _quoteTextController.text = quote.quoteText;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: const Color(0xFFFFF8E1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.edit,
                        color: Color(0xFF8D6748),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Edit Quote',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF8D6748),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0C9A6)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widget.book.coverImagePath != null && widget.book.coverImagePath!.isNotEmpty
                              ? Image.network(
                                  _getBookCoverImageUrl(widget.book.coverImagePath),
                                  width: 60,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0C9A6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.book,
                                        size: 30,
                                        color: Color(0xFF8D6748),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: 60,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0C9A6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.book,
                                    size: 30,
                                    color: Color(0xFF8D6748),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.book.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.book.authorName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8D6748),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Edit your quote',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: _quoteTextController,
                    maxLines: 6,
                    maxLength: 10000,
                    decoration: InputDecoration(
                      hintText: 'Enter your favorite quote from this book...',
                      hintStyle: const TextStyle(color: Color(0xFF8D6748)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0C9A6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF8D6748), width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                 
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF8D6748),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmittingQuote ? null : () => _updateQuote(dialogContext, quote),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8D6748),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmittingQuote
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Update Quote',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
      ),
    );
  }

  void _showDeleteQuoteDialog(Quote quote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8E1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete Quote',
          style: TextStyle(
            color: Color(0xFF5D4037),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this quote? This action cannot be undone.',
          style: TextStyle(
            color: Color(0xFF5D4037),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8D6748)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteQuote(quote);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuote(BuildContext dialogContext) async {
    final quoteText = _quoteTextController.text.trim();
    
    if (quoteText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quote text cannot be empty.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    if (quoteText.length > 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quote text cannot exceed 10,000 characters.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmittingQuote = true;
    });
    
    try {
      final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final username = AuthProvider.username;
      if (username == null) throw Exception('No user logged in');
      
      final userResult = await userProvider.get(filter: {'username': username, 'pageSize': 1});
      final user = userResult.items?.first;
      if (user == null) throw Exception('User not found');
      
      final request = {
        'userId': user.id,
        'bookId': widget.book.id,
        'quoteText': quoteText,
      };
      
      
      await quoteProvider.insert(request);
      
      Navigator.of(dialogContext).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Quote added successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF8D6748),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      
      await _loadQuotes();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error adding quote: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() {
        _isSubmittingQuote = false;
      });
    }
  }

  Future<void> _updateQuote(BuildContext dialogContext, Quote quote) async {
    final quoteText = _quoteTextController.text.trim();
    
    if (quoteText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quote text cannot be empty.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    if (quoteText.length > 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quote text cannot exceed 10,000 characters.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmittingQuote = true;
    });
    
    try {
      final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
      
      final request = {
        'userId': quote.userId,
        'bookId': quote.bookId,
        'quoteText': quoteText,
      };
      
      
      await quoteProvider.update(quote.id, request);
      
      Navigator.of(dialogContext).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Quote updated successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF8D6748),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      
      await _loadQuotes();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating quote: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() {
        _isSubmittingQuote = false;
      });
    }
  }

  Future<void> _deleteQuote(Quote quote) async {
    try {
      final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
      
      
      await quoteProvider.delete(quote.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Quote deleted successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF8D6748),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      
      await _loadQuotes();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting quote: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _showAddToListDialog() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final readingListProvider = Provider.of<ReadingListProvider>(context, listen: false);
    final username = AuthProvider.username;
    if (username == null) return;
    final userResult = await userProvider.get(filter: {'username': username, 'pageSize': 1});
    final currentUser = userResult.items != null && userResult.items!.isNotEmpty ? userResult.items!.first : null;
    if (currentUser == null) return;
    final lists = await readingListProvider.getUserReadingLists(currentUser.id);
    final defaultListNames = ['Read', 'Want to read', 'Currently reading'];
    List<dynamic> defaultLists = lists.where((l) => defaultListNames.contains(l.name)).toList();
    List<dynamic> customLists = lists.where((l) => !defaultListNames.contains(l.name)).toList();

    int? selectedDefaultListId;
    Set<int> selectedCustomListIds = {};
    Set<int> newlyCreatedListIds = {}; // To store the IDs of all newly created lists

    if (widget.preselectedListId != null) {
      final preselected = lists.firstWhere((l) => l.id == widget.preselectedListId, orElse: () => defaultLists.isNotEmpty ? defaultLists.first : lists.first);
      if (defaultListNames.contains(preselected.name)) {
        selectedDefaultListId = preselected.id;
      } else {
        selectedCustomListIds.add(preselected.id);
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFFFFF8E1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Add book to your library',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8D6748)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Note: Adding to "Read" list will ask for the date you finished reading.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      ...defaultLists.map((list) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Color(0xFFD7B899),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setDialogState(() {
                                selectedDefaultListId = list.id;
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    child: Text(
                                      list.name,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4E342E)),
                                    ),
                                  ),
                                ),
                                Radio<int>(
                                  value: list.id,
                                  groupValue: selectedDefaultListId,
                                  onChanged: (val) {
                                    setDialogState(() {
                                      selectedDefaultListId = val;
                                    });
                                  },
                                  activeColor: Color(0xFF8D6748),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                      SizedBox(height: 16),
                      Text('Your custom lists', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF8D6748))),
                      SizedBox(height: 8),
                      Material(
                        color: Color(0xFFFFE0B2),
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () async {
                            print('DEBUG: Creating new list...');
                            final newListId = await _showCreateListDialog(context, setDialogState);
                            print('DEBUG: New list created with ID: $newListId');
                            
                            if (newListId != null) {
                              print('DEBUG: Refreshing lists...');
                              // Refresh the lists to include the newly created one
                              final userProvider = Provider.of<UserProvider>(context, listen: false);
                              final readingListProvider = Provider.of<ReadingListProvider>(context, listen: false);
                              final username = AuthProvider.username;
                              
                              if (username != null) {
                                final userResult = await userProvider.get(filter: {'username': username, 'pageSize': 1});
                                final currentUser = userResult.items != null && userResult.items!.isNotEmpty ? userResult.items!.first : null;
                                
                                if (currentUser != null) {
                                  final updatedLists = await readingListProvider.getUserReadingLists(currentUser.id);
                                  final defaultListNames = ['Read', 'Want to read', 'Currently reading'];
                                  final updatedDefaultLists = updatedLists.where((l) => defaultListNames.contains(l.name)).toList();
                                  final updatedCustomLists = updatedLists.where((l) => !defaultListNames.contains(l.name)).toList();
                                  
                                  print('DEBUG: Updated custom lists count: ${updatedCustomLists.length}');
                                  print('DEBUG: Updated custom lists: ${updatedCustomLists.map((l) => '${l.id}:${l.name}').join(', ')}');
                                  
                                  setDialogState(() {
                                    // Update the lists in the dialog
                                    defaultLists.clear();
                                    defaultLists.addAll(updatedDefaultLists);
                                    customLists.clear();
                                    customLists.addAll(updatedCustomLists);
                                    
                                    // Add the newly created list ID to the set and select it
                                    newlyCreatedListIds.add(newListId);
                                    selectedCustomListIds.add(newListId);
                                    
                                    print('DEBUG: After setDialogState - customLists count: ${customLists.length}');
                                    print('DEBUG: After setDialogState - selectedCustomListIds: $selectedCustomListIds');
                                    print('DEBUG: newlyCreatedListIds: $newlyCreatedListIds');
                                  });
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: Row(
                              children: [
                                Icon(Icons.add, color: Color(0xFF8D6748)),
                                SizedBox(width: 8),
                                Text('Create a new list', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF8D6748))),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                 
                      ...customLists.map((list) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(24),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              setDialogState(() {
                                if (selectedCustomListIds.contains(list.id)) {
                                  selectedCustomListIds.remove(list.id);
                                } else {
                                  selectedCustomListIds.add(list.id);
                                }
                              });
                            },
                            child: Row(
                              children: [
                                if (list.coverImagePath != null && list.coverImagePath!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(_buildImageUrl(list.coverImagePath!)),
                                      radius: 18,
                                    ),
                                  ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    child: Text(
                                      list.name,
                                      style: TextStyle(fontSize: 15, color: Color(0xFF4E342E)),
                                    ),
                                  ),
                                ),
                                Checkbox(
                                  value: selectedCustomListIds.contains(list.id),
                                  onChanged: (val) {
                                    setDialogState(() {
                                      if (val == true) {
                                        selectedCustomListIds.add(list.id);
                                      } else {
                                        selectedCustomListIds.remove(list.id);
                                      }
                                    });
                                  },
                                  activeColor: Color(0xFF8D6748),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel'),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              List<String> alreadyInLists = [];
                              List<int> validDefaultListIds = [];
                              List<int> validCustomListIds = [];
                              
                              // Check default list
                              if (selectedDefaultListId != null) {
                                final defaultList = lists.firstWhere((l) => l.id == selectedDefaultListId);
                                if (defaultList.books.any((book) => book.bookId == widget.book.id)) {
                                  alreadyInLists.add(defaultList.name);
                                } else {
                                  validDefaultListIds.add(selectedDefaultListId!);
                                }
                              }
                              

                              
                              print('DEBUG: Checking custom lists...');
                              print('DEBUG: selectedCustomListIds: $selectedCustomListIds');
                              print('DEBUG: Available lists: ${lists.map((l) => '${l.id}:${l.name}').join(', ')}');
                              
                              // Check custom lists
                              for (final listId in selectedCustomListIds) {
                                print('DEBUG: Checking list ID: $listId');
                                
                                // Handle newly created lists
                                if (newlyCreatedListIds.contains(listId)) {
                                  // Newly created lists won't have the book yet, so they're valid
                                  validCustomListIds.add(listId);
                                  print('DEBUG: Added newly created list to validCustomListIds: $listId');
                                } else {
                                  // Handle existing custom lists
                                  try {
                                    final customList = lists.firstWhere((l) => l.id == listId);
                                    print('DEBUG: Found list: ${customList.name} (ID: $listId)');
                                    if (customList.books.any((book) => book.bookId == widget.book.id)) {
                                      alreadyInLists.add(customList.name);
                                      print('DEBUG: Book already in list: ${customList.name}');
                                    } else {
                                      validCustomListIds.add(listId);
                                      print('DEBUG: Added to validCustomListIds: $listId');
                                    }
                                  } catch (e) {
                                    print('DEBUG: Error finding list $listId: $e');
                                  }
                                }
                              }
                              
                              print('DEBUG: validCustomListIds: $validCustomListIds');
                              

                             
                              List<String> inOtherDefaultLists = [];
                              for (final defaultList in defaultLists) {
                                if (defaultList.id != selectedDefaultListId && 
                                    defaultList.books.any((book) => book.bookId == widget.book.id)) {
                                  inOtherDefaultLists.add(defaultList.name);
                                }
                              }
                              
                              // If no valid lists to add to, show error and return
                              if (validDefaultListIds.isEmpty && validCustomListIds.isEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Book Already in Lists'),
                                    content: Text('This book is already in all selected lists: ${alreadyInLists.join(', ')}'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                              
                              // Show warning for lists where book is already present
                              if (alreadyInLists.isNotEmpty) {
                                final shouldContinue = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Book Already in Some Lists'),
                                    content: Text('This book is already in: ${alreadyInLists.join(', ')}\n\nIt will be added to the other selected lists.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: Text('Continue'),
                                      ),
                                    ],
                                  ),
                                );
                                
                                if (shouldContinue != true) {
                                  return;
                                }
                              }
                              
                              // Handle default list moving logic
                              if (validDefaultListIds.isNotEmpty && inOtherDefaultLists.isNotEmpty) {
                                final shouldContinue = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Moving Book'),
                                    content: Text('This book will be moved from: ${inOtherDefaultLists.join(', ')}'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: Text('Continue'),
                                      ),
                                    ],
                                  ),
                                );
                                
                                if (shouldContinue != true) {
                                  return;
                                }
                              }
                              
                              final readingListProvider = Provider.of<ReadingListProvider>(context, listen: false);
                              bool hasError = false;
                              String errorMessage = '';
                              List<String> successfullyAddedLists = [];
                              
                              // Add to valid default lists
                              for (final defaultListId in validDefaultListIds) {
                                // Remove from other default lists if moving
                                for (final defaultList in defaultLists) {
                                  if (defaultList.id != defaultListId && 
                                      defaultList.books.any((book) => book.bookId == widget.book.id)) {
                                    await readingListProvider.removeBookFromList(defaultList.id, widget.book.id);
                                  }
                                }
                                
                                // Check if this is the "Read" list and ask for read date
                                DateTime? readAt;
                                if (defaultLists.any((list) => list.id == defaultListId && list.name.toLowerCase() == "read")) {
                                  readAt = await _showReadDateDialog(context);
                                  if (readAt == null) {
                                    // User cancelled the date selection
                                    return;
                                  }
                                }
                                
                                final result = await readingListProvider.addBookToList(defaultListId, widget.book.id, readAt: readAt);
                                if (result == null) {
                                  hasError = true;
                                  errorMessage = 'Failed to add book to default list';
                                } else {
                                  final listName = lists.firstWhere((l) => l.id == defaultListId).name;
                                  successfullyAddedLists.add(listName);
                                }
                              }
                              

                              
                              print('DEBUG: Starting to add books to custom lists: $validCustomListIds');
                              print('DEBUG: Available custom lists: ${customLists.map((l) => '${l.id}:${l.name}').join(', ')}');
                              
                              // Add to valid custom lists
                              for (final listId in validCustomListIds) {
                                print('DEBUG: Processing list ID: $listId');
                                
                                try {
                                  // Check if this is a "Read" list and ask for read date
                                  DateTime? readAt;
                                  final customList = customLists.firstWhere((list) => list.id == listId);
                                  final listName = customList.name;
                                  
                                  print('DEBUG: Found list: $listName (ID: $listId)');
                                  
                                  if (customList.name.toLowerCase() == "read") {
                                    readAt = await _showReadDateDialog(context);
                                    if (readAt == null) {
                                      // User cancelled the date selection
                                      return;
                                    }
                                  }
                                  
                                  print('DEBUG: Adding book ${widget.book.id} to list $listId ($listName)');
                                  final result = await readingListProvider.addBookToList(listId, widget.book.id, readAt: readAt);
                                  if (result == null) {
                                    hasError = true;
                                    errorMessage = 'Failed to add book to custom list';
                                    print('DEBUG: Failed to add book to list $listId');
                                  } else {
                                    successfullyAddedLists.add(listName);
                                    print('DEBUG: Successfully added book to list $listId ($listName)');
                                  }
                                } catch (e) {
                                  print('DEBUG: Error processing list $listId: $e');
                                  hasError = true;
                                  errorMessage = 'Error processing list: $e';
                                }
                              }
                              
                              Navigator.of(context).pop();
                              
                              // Show appropriate message based on results
                              if (hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else if (successfullyAddedLists.isNotEmpty) {
                                String message;
                                if (alreadyInLists.isNotEmpty) {
                                  message = 'Book added to: ${successfullyAddedLists.join(', ')}\nAlready in: ${alreadyInLists.join(', ')}';
                                } else {
                                  message = 'Book added to: ${successfullyAddedLists.join(', ')}';
                                }
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 4),
                                  ),
                                );
                                
                                Navigator.of(context).pop(true);
                              } else {
                                // This shouldn't happen, but just in case
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('No lists were selected or all selected lists already contain this book.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8D6748),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Add'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<DateTime?> _showReadDateDialog(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    
    return await showDialog<DateTime>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 500,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'When did you read this book?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8D6748),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select the date you finished reading this book:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  onDateChanged: (date) {
                    selectedDate = date;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(selectedDate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8D6748),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int?> _showCreateListDialog(BuildContext context, StateSetter setDialogState) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    File? selectedImage;
    String? nameError;
    String? descriptionError;
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setCreateDialogState) => AlertDialog(
          title: Text('Create New Reading List'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedImage != null)
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFF8D6E63)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                      allowMultiple: false,
                    );
                    if (result != null && result.files.isNotEmpty) {
                      setCreateDialogState(() {
                        selectedImage = File(result.files.first.path!);
                      });
                    }
                  },
                  icon: Icon(Icons.image),
                  label: Text(selectedImage != null ? 'Change Image' : 'Add Cover Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8D6E63),
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'List Name *',
                    border: OutlineInputBorder(),
                    hintText: 'Enter list name',
                  ),
                  maxLength: 100,
                  onChanged: (value) {
                    setCreateDialogState(() {
                      nameError = null;
                    });
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
                SizedBox(height: 16),
                
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                    hintText: 'Enter list description',
                  ),
                  maxLength: 300,
                  maxLines: 3,
                  onChanged: (value) {
                    setCreateDialogState(() {
                      descriptionError = null;
                    });
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                setCreateDialogState(() {
                  if (nameController.text.trim().isEmpty) {
                    nameError = 'Name is required.';
                  } else if (nameController.text.length > 100) {
                    nameError = 'Name must not exceed 100 characters.';
                  } else {
                    // Check for default list names
                    final defaultNames = ['Want to read', 'Currently reading', 'Read'];
                    final inputName = nameController.text.trim();
                    if (defaultNames.any((defaultName) => 
                        defaultName.toLowerCase() == inputName.toLowerCase())) {
                      nameError = 'This name is reserved for default lists. Please choose a different name.';
                    }
                  }
                  
                  if (descriptionController.text.trim().isEmpty) {
                    descriptionError = 'Description is required.';
                  } else if (descriptionController.text.length > 300) {
                    descriptionError = 'Description must not exceed 300 characters.';
                  }
                });
                
                if (nameError != null || descriptionError != null) {
                  return;
                }
                
                // Check for duplicate names by fetching user's existing lists
                try {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  final readingListProvider = Provider.of<ReadingListProvider>(context, listen: false);
                  final username = AuthProvider.username;
                  
                  if (username != null) {
                    final userResult = await userProvider.get(filter: {'username': username, 'pageSize': 1});
                    final currentUser = userResult.items != null && userResult.items!.isNotEmpty ? userResult.items!.first : null;
                    
                    if (currentUser != null) {
                      final existingLists = await readingListProvider.getUserReadingLists(currentUser.id);
                      final inputName = nameController.text.trim();
                      
                      if (existingLists.any((list) => list.name.toLowerCase() == inputName.toLowerCase())) {
                        setCreateDialogState(() {
                          nameError = 'A reading list with this name already exists.';
                        });
                        return;
                      }
                    }
                  }
                } catch (e) {
                  // If we can't check for duplicates, continue anyway
                  print('Could not check for duplicate names: $e');
                }
                
                Navigator.of(context).pop({
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'image': selectedImage,
                });
              },
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      try {
        final provider = Provider.of<ReadingListProvider>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final username = AuthProvider.username;
        
        if (username != null) {
          final userResult = await userProvider.get(filter: {'username': username, 'pageSize': 1});
          final currentUser = userResult.items != null && userResult.items!.isNotEmpty ? userResult.items!.first : null;
          
          if (currentUser != null) {
            var newList = await provider.create({
              'userId': currentUser.id,
              'name': result['name'],
              'description': result['description'],
              'isPublic': true,
              'bookIds': [],
            });

            if (result['image'] != null) {
              final updatedList = await provider.uploadCover(newList.id, result['image']);
              if (updatedList != null) {
                newList = updatedList;
              }
            }

            // Don't ask for read date here - it will be asked in the main dialog if needed
            // Just create the list and return its ID
            
            // Don't add the book here - it will be added in the main dialog
            // Return the newly created list ID so it can be added to the selected lists
            return newList.id;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('User not found'),
                backgroundColor: Colors.red,
              ),
            );
            return null;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Not logged in'),
              backgroundColor: Colors.red,
            ),
          );
          return null;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating reading list: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    }
    
    return null; // Return null if no list was created
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
}
