import 'package:bookworm_mobile/providers/auth_provider.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/author_provider.dart';
import '../providers/bookReview_provider.dart';
import '../providers/user_provider.dart';
import '../model/book.dart';
import '../model/author.dart';
import '../model/bookReview.dart';
import '../model/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookDetailsScreen extends StatefulWidget {
  final Book book;

  const BookDetailsScreen({Key? key, required this.book}) : super(key: key);

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
  
  
  int _selectedRating = 0;
  final TextEditingController _reviewTextController = TextEditingController();
  bool _isSubmittingReview = false;
  BookReview? _userReview; // Track if user already has a review

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadBookRating();
    _loadAuthor();
    _loadReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewTextController.dispose();
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
      print('Loading author for book ID: ${widget.book.id}, author ID: ${widget.book.authorId}');
      setState(() {
        _isLoadingAuthor = true;
      });
      
      final authorProvider = Provider.of<AuthorProvider>(context, listen: false);
      final author = await authorProvider.getById(widget.book.authorId);
      
      print('Author loaded successfully: ${author.name}');
      setState(() {
        _author = author;
        _isLoadingAuthor = false;
      });
    } catch (e) {
      print('Error loading author: $e');
      setState(() {
        _isLoadingAuthor = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    try {
      print('===REVIEWS=== Loading reviews for book ID: ${widget.book.id}');
      setState(() {
        _isLoadingReviews = true;
      });
      
      final reviewProvider = Provider.of<BookReviewProvider>(context, listen: false);
      final filter = {
        'bookId': widget.book.id,
        'pageSize': 50,
        'page': 0,
      };
      print('===REVIEWS=== Filter: $filter');
      
      final result = await reviewProvider.get(filter: filter);
      print('===REVIEWS=== Result: ${result.items?.length ?? 0} reviews found');
      
      final reviews = result.items ?? [];
      
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
      
      print('===REVIEWS=== Reviews loaded: ${reviews.length}');
      
      await _loadUsersForReviews(reviews);
      
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
        
        _userReview = _reviews.firstWhere(
          (review) {
            final user = _users[review.userId];
            return user?.username == currentUsername;
          },
          orElse: () => null as BookReview,
        );
        
        setState(() {
        });
      }
    } catch (e) {
      print('===REVIEWS=== Error loading reviews: $e');
      setState(() {
        _isLoadingReviews = false;
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
    } catch (e) {
      print('Error loading users for reviews: $e');
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
          onPressed: () => Navigator.pop(context),
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
                      onPressed: () {
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
                      child: Text(_userReview != null ? 'Edit Rating' : 'Rate'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                       
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
    return const Center(
      child: Text(
        'Quotes coming soon...',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF8D6748),
        ),
      ),
    );
  }

  void _showAddReviewDialog() {
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
      
      print('===REVIEWS=== Updating review: $request');
      
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
      print('===REVIEWS=== Error updating review: $e');
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
      
      print('===REVIEWS=== Deleting review: ${review.id}');
      
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
      
     
      _userReview = null;
      
    } catch (e) {
      print('===REVIEWS=== Error deleting review: $e');
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
      
      print('===REVIEWS=== Submitting review: $request');
      
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
      print('===REVIEWS=== Error submitting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error submitting review: ${e.toString()}',
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
}
