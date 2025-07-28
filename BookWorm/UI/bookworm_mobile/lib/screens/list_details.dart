import 'package:bookworm_mobile/model/reading_list_book.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookworm_mobile/providers/reading_list_provider.dart';
import 'package:bookworm_mobile/model/reading_list.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:bookworm_mobile/screens/book_details.dart';

class ListDetailsScreen extends StatefulWidget {
  final ReadingList readingList;

  const ListDetailsScreen({Key? key, required this.readingList}) : super(key: key);

  @override
  State<ListDetailsScreen> createState() => _ListDetailsScreenState();
}

class _ListDetailsScreenState extends State<ListDetailsScreen> {
  ReadingList? _currentList;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadListDetails();
  }

  Future<void> _loadListDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ReadingListProvider>(context, listen: false);
      final updatedList = await provider.getById(widget.readingList.id);
      
      setState(() {
        _currentList = updatedList ?? widget.readingList;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading list details: $e');
      setState(() {
        _currentList = widget.readingList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _currentList ?? widget.readingList;
    
    return Scaffold(
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
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // TODO: Add book to list functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Add book functionality coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Description Section
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
                
                // Filter/Sort Bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            _buildFilterButton('Genre', Icons.keyboard_arrow_down),
                            SizedBox(width: 8),
                            _buildFilterButton('Sort', Icons.keyboard_arrow_down),
                            SizedBox(width: 8),
                            _buildFilterButton('Pick for me', null),
                          ],
                        ),
                      ),
                      Icon(Icons.menu_book, color: Color(0xFF8D6748)),
                    ],
                  ),
                ),
                
                // Books List
                Expanded(
                  child: list.books.isEmpty
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
                          itemCount: list.books.length,
                          itemBuilder: (context, index) {
                            final book = list.books[index];
                            return _buildBookItem(book, list);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterButton(String text, IconData? icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF8D6748),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (icon != null) ...[
            SizedBox(width: 4),
            Icon(icon, color: Colors.white, size: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildBookItem(ReadingListBook book, ReadingList list) {
    String? imageUrl;
    if (book.coverImagePath != null && book.coverImagePath!.isNotEmpty) {
      imageUrl = _buildImageUrl(book.coverImagePath!);
    }
    
    return Container(
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
            Row(
              children: [
                Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                Icon(Icons.star_border, color: Color(0xFFFFD700), size: 16),
                SizedBox(width: 8),
                Text(
                  '50 Ratings',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Color(0xFF8D6E63)),
          onSelected: (value) => _handleBookAction(value, book, list),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 18),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.remove_circle, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Remove from List', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _navigateToBookDetails(book),
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
    switch (action) {
      case 'view':
        _navigateToBookDetails(book);
        break;
      case 'remove':
        _removeBookFromList(book, list);
        break;
    }
  }

  void _navigateToBookDetails(ReadingListBook book) {
    // TODO: Navigate to book details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Book details coming soon!')),
    );
  }

  Future<void> _removeBookFromList(ReadingListBook book, ReadingList list) async {
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
            SnackBar(
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
} 