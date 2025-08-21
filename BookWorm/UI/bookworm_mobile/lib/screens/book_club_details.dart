import 'package:flutter/material.dart';
import 'package:bookworm_mobile/model/book_club.dart';
import 'package:bookworm_mobile/model/book_club_event.dart';
import 'package:bookworm_mobile/providers/book_club_provider.dart';
import 'package:bookworm_mobile/providers/book_provider.dart';
import 'package:bookworm_mobile/providers/user_provider.dart';
import 'package:bookworm_mobile/providers/book_club_event_provider.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:bookworm_mobile/model/book.dart';
import 'package:bookworm_mobile/model/user.dart';
import 'package:bookworm_mobile/screens/book_details.dart';
import 'package:bookworm_mobile/screens/user_profile.dart';

class BookClubDetailsScreen extends StatefulWidget {
  final BookClub bookClub;
  
  const BookClubDetailsScreen({Key? key, required this.bookClub}) : super(key: key);

  @override
  State<BookClubDetailsScreen> createState() => _BookClubDetailsScreenState();
}

class _BookClubDetailsScreenState extends State<BookClubDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookClubProvider _bookClubProvider = BookClubProvider();
  final BookProvider _bookProvider = BookProvider();
  final UserProvider _userProvider = UserProvider();
  final BookClubEventProvider _eventProvider = BookClubEventProvider();
  
  late BookClub _currentBookClub;
  List<BookClubEvent> _events = [];
  List<Map<String, dynamic>> _members = [];
  Map<int, Book> _eventBooks = {};
  List<Book> _availableBooks = [];
  bool _isLoading = true;
  bool _isJoining = false;
  bool _isDialogOpen = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentBookClub = widget.bookClub;
    _loadBookClubDetails();
  }

  Future<void> _loadBookClubDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookClubFuture = _bookClubProvider.getById(_currentBookClub.id);
      final eventsFuture = _bookClubProvider.getBookClubEvents(_currentBookClub.id);
      final membersFuture = _bookClubProvider.getBookClubMembers(_currentBookClub.id);
      final booksFuture = _bookProvider.getAllBooks();
      
      final results = await Future.wait([bookClubFuture, eventsFuture, membersFuture, booksFuture]);
      
      final updatedBookClub = results[0] as BookClub;
      final events = results[1] as List<BookClubEvent>;
      final members = results[2] as List<Map<String, dynamic>>;
      final availableBooks = results[3] as List<Book>;
      
      final bookIds = events.map((e) => e.bookId).toSet();
      final books = <int, Book>{};
      
      for (int bookId in bookIds) {
        try {
          final book = await _bookProvider.getById(bookId);
          books[bookId] = book;
        } catch (e) {
          print('Error loading book $bookId: $e');
        }
      }

      setState(() {
        _currentBookClub = updatedBookClub;
        _events = events;
        _members = members;
        _eventBooks = books;
        _availableBooks = availableBooks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load book club details.';
        _isLoading = false;
      });
    }
  }

  Future<void> _joinBookClub() async {
    setState(() {
      _isJoining = true;
    });

    try {
      await _bookClubProvider.joinBookClub(_currentBookClub.id);
      await _loadBookClubDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined the book club!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join book club: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }

  Future<void> _leaveBookClub() async {
    setState(() {
      _isJoining = true;
    });

    try {
      await _bookClubProvider.leaveBookClub(_currentBookClub.id);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully left the book club!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to leave book club: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }

  Future<void> _navigateToUserProfile(int userId) async {
    try {
      final user = await _userProvider.getById(userId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(user: user),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load user profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _participateInEvent(BookClubEvent event) async {
    try {
      await _eventProvider.participateInEvent(event.id);
      await _loadBookClubDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined the event!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join event: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _leaveEvent(BookClubEvent event) async {
    try {
      await _eventProvider.leaveEvent(event.id);
      await _loadBookClubDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully left the event!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to leave event: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markEventAsCompleted(BookClubEvent event) async {
    try {
      await _eventProvider.markEventAsCompleted(event.id);
      await _loadBookClubDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event marked as completed!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark event as completed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editBookClub() async {
    final nameController = TextEditingController(text: _currentBookClub.name);
    final descriptionController = TextEditingController(text: _currentBookClub.description);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Book Club'),
        content: Form(
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
                maxLines: 3,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                await _updateBookClub(nameController.text, descriptionController.text);
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

  Future<void> _updateBookClub(String name, String description) async {
    try {
      final updatedBookClub = await _bookClubProvider.updateBookClub(_currentBookClub.id, name, description);
      setState(() {
        _currentBookClub = updatedBookClub;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book club updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update book club: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteBookClub() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book Club'),
        content: const Text('Are you sure you want to delete this book club? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDeleteBookClub();
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

  Future<void> _confirmDeleteBookClub() async {
    try {
      await _bookClubProvider.deleteBookClub(_currentBookClub.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book club deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete book club: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showCreateEventDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime selectedDeadline = DateTime.now().add(const Duration(days: 7));
    Book? selectedBook;

    setState(() {
      _isDialogOpen = true;
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Event'),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.4,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Event Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title is required';
                        }
                        if (value.length > 200) {
                          return 'Title must be less than 200 characters';
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
                        if (value.length > 700) {
                          return 'Description must be less than 700 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Deadline'),
                      subtitle: Text(
                        '${selectedDeadline.day}/${selectedDeadline.month}/${selectedDeadline.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDeadline,
                          firstDate: DateTime.now().add(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDeadline = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              selectedDeadline.hour,
                              selectedDeadline.minute,
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _showBookSelectionDialog(context, selectedBook, (book) {
                        setState(() {
                          selectedBook = book;
                        });
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: selectedBook == null ? Colors.red : Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedBook != null 
                                  ? '${selectedBook!.title} by ${selectedBook!.authorName}'
                                  : 'Select Book *',
                                style: TextStyle(
                                  color: selectedBook != null ? Colors.black : Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    if (selectedBook == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          'Please select a book',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isDialogOpen = false;
                });
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate() && selectedBook != null) {
                  Navigator.pop(context);
                  setState(() {
                    _isDialogOpen = false;
                  });
                  await _createEvent(
                    titleController.text,
                    descriptionController.text,
                    selectedDeadline,
                    selectedBook!.id,
                  );
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
    ).then((_) {
      // This ensures _isDialogOpen is set to false when dialog is closed by any means
      if (mounted) {
        setState(() {
          _isDialogOpen = false;
        });
      }
    });
  }

  Future<void> _createEvent(String title, String description, DateTime deadline, int bookId) async {
    try {
      await _eventProvider.createEvent(title, description, deadline, bookId, _currentBookClub.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadBookClubDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create event: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editEvent(BookClubEvent event) async {
    final titleController = TextEditingController(text: event.title);
    final descriptionController = TextEditingController(text: event.description);
    final formKey = GlobalKey<FormState>();
    DateTime selectedDeadline = event.deadline;
    Book? selectedBook;

    try {
      selectedBook = _availableBooks.firstWhere((book) => book.id == event.bookId);
    } catch (e) {
      print('Error finding book: $e');
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Event'),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.4,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Event Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title is required';
                        }
                        if (value.length > 200) {
                          return 'Title must be less than 200 characters';
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
                        if (value.length > 700) {
                          return 'Description must be less than 700 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Deadline'),
                      subtitle: Text(
                        '${selectedDeadline.day}/${selectedDeadline.month}/${selectedDeadline.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDeadline,
                          firstDate: DateTime.now().add(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDeadline = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              selectedDeadline.hour,
                              selectedDeadline.minute,
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _showBookSelectionDialog(context, selectedBook, (book) {
                        setState(() {
                          selectedBook = book;
                        });
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: selectedBook == null ? Colors.red : Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedBook != null 
                                  ? '${selectedBook!.title} by ${selectedBook!.authorName}'
                                  : 'Select Book *',
                                style: TextStyle(
                                  color: selectedBook != null ? Colors.black : Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    if (selectedBook == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          'Please select a book',
                          style: TextStyle(color: Colors.red, fontSize: 12),
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
                if (formKey.currentState!.validate() && selectedBook != null) {
                  Navigator.pop(context);
                  await _updateEvent(
                    event.id,
                    titleController.text,
                    descriptionController.text,
                    selectedDeadline,
                    selectedBook!.id,
                  );
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

  Future<void> _updateEvent(int eventId, String title, String description, DateTime deadline, int bookId) async {
    try {
      await _eventProvider.updateEvent(eventId, title, description, deadline, bookId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadBookClubDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update event: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteEvent(BookClubEvent event) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDeleteEvent(event.id);
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

  Future<void> _confirmDeleteEvent(int eventId) async {
    try {
      await _eventProvider.deleteEvent(eventId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadBookClubDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete event: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildEventCard(BookClubEvent event) {
    final book = _eventBooks[event.bookId];
    final bookTitle = event.bookTitle.isNotEmpty ? event.bookTitle : (book?.title ?? 'Unknown Book');
    final bookAuthor = event.bookAuthorName.isNotEmpty ? event.bookAuthorName : (book?.authorName ?? 'Unknown Author');
    final bookCoverPath = event.bookCoverImagePath.isNotEmpty ? event.bookCoverImagePath : (book?.coverImagePath ?? '');
    final isExpired = event.deadline.isBefore(DateTime.now());
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: const Color(0xFF8D6748), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                ),
                if (event.isCreator) ...[
                  IconButton(
                    onPressed: () => _editEvent(event),
                    icon: const Icon(Icons.edit, color: Color(0xFF8D6748), size: 18),
                    tooltip: 'Edit Event',
                  ),
                  IconButton(
                    onPressed: () => _deleteEvent(event),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                    tooltip: 'Delete Event',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(
                color: Color(0xFF8D6748),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            if (book != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailsScreen(book: book),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF8D6748), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFF8D6748),
                        ),
                        child: bookCoverPath.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _buildImageUrl(bookCoverPath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.book,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.book,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bookTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF5D4037),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'by $bookAuthor',
                              style: const TextStyle(
                                color: Color(0xFF8D6748),
                                fontSize: 12,
                              ),
                            ),
                            if (book.publicationYear > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Published: ${book.publicationYear}',
                                style: const TextStyle(
                                  color: Color(0xFF8D6748),
                                  fontSize: 11,
                                ),
                              ),
                            ],
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
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, color: isExpired ? Colors.red : const Color(0xFF8D6748), size: 16),
                const SizedBox(width: 4),
                Text(
                  'Deadline: ${_formatDate(event.deadline)}',
                  style: TextStyle(
                    color: isExpired ? Colors.red : const Color(0xFF8D6748),
                    fontSize: 12,
                    fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isExpired) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'EXPIRED',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, color: const Color(0xFF8D6748), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${event.participantsCount} participants',
                  style: const TextStyle(
                    color: Color(0xFF8D6748),
                    fontSize: 12,
                  ),
                ),
                if (event.completedParticipantsCount > 0) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${event.completedParticipantsCount} completed',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (isExpired) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'This event has expired and is no longer accepting participants',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ] else ...[
              if (_currentBookClub.isMember) ...[
                if (!event.isParticipant)
                  ElevatedButton(
                    onPressed: () => _participateInEvent(event),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8D6748),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Join Event',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                if (event.isParticipant) ...[
                  Row(
                    children: [
                      if (!event.isCompleted)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _leaveEvent(event),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text(
                              'Leave Event',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      if (!event.isCompleted) const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: event.isCompleted ? null : () => _markEventAsCompleted(event),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: event.isCompleted ? Colors.grey : Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            event.isCompleted ? 'Completed' : 'Mark Complete',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Join the book club to participate in events',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],

          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF8D6748),
          child: Text(
            member['userName']?.substring(0, 1).toUpperCase() ?? 'U',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          member['userName'] ?? 'Unknown User',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037),
          ),
        ),
        subtitle: Text(
          member['userEmail'] ?? '',
          style: const TextStyle(color: Color(0xFF8D6748)),
        ),
        trailing: Text(
          'Joined ${_formatDate(DateTime.parse(member['joinedAt']))}',
          style: const TextStyle(
            color: Color(0xFF8D6748),
            fontSize: 12,
          ),
        ),
        onTap: () {
          _navigateToUserProfile(member['userId']);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildJoinLeaveButton() {
    if (_currentBookClub.isCreator) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8D6748),
            disabledBackgroundColor: const Color(0xFF8D6748),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: const Text(
            'You are the creator',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else if (_currentBookClub.isMember) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isJoining ? null : _leaveBookClub,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: _isJoining
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'Leave Book Club',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isJoining ? null : _joinBookClub,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8D6748),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: _isJoining
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'Join Book Club',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
      );
    }
  }

  void _showBookSelectionDialog(BuildContext context, Book? selectedBook, Function(Book?) onBookSelected) {
    final searchController = TextEditingController();
    List<Book> availableBooksForSelection = _availableBooks.where((book) {
      if (selectedBook?.id == book.id) return true;
      
      return !_events.any((event) => event.bookId == book.id);
    }).toList();
    
    List<Book> filteredBooks = availableBooksForSelection;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Book'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search books...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredBooks = availableBooksForSelection.where((book) =>
                        book.title.toLowerCase().contains(value.toLowerCase()) ||
                        book.authorName.toLowerCase().contains(value.toLowerCase())
                      ).toList();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredBooks.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.book_outlined,
                                size: 48,
                                color: Color(0xFF8D6748),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No available books',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF8D6748),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'All books are already used in events.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8D6748),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = filteredBooks[index];
                            return ListTile(
                              title: Text(
                                book.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                'by ${book.authorName}',
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: selectedBook?.id == book.id
                                  ? const Icon(Icons.check, color: Color(0xFF8D6748))
                                  : null,
                              onTap: () {
                                onBookSelected(book);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          color: const Color(0xFFFFF8E1),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF8D6748)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Book Club Details',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ),
                      if (_currentBookClub.isCreator) ...[
                        IconButton(
                          onPressed: _editBookClub,
                          icon: const Icon(Icons.edit, color: Color(0xFF8D6748)),
                          tooltip: 'Edit Book Club',
                        ),
                        IconButton(
                          onPressed: _deleteBookClub,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete Book Club',
                        ),
                      ],
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF8D6748),
                  labelColor: const Color(0xFF8D6748),
                  unselectedLabelColor: const Color(0xFF5D4037),
                  labelStyle: const TextStyle(fontFamily: 'Literata', fontWeight: FontWeight.bold, fontSize: 16),
                  tabs: const [
                    Tab(text: 'Events'),
                    Tab(text: 'Members'),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF8E1),
                        border: Border(
                          bottom: BorderSide(color: Color(0xFF8D6748), width: 1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentBookClub.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentBookClub.description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF8D6748),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.people, color: const Color(0xFF8D6748), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${_members.length} members',
                                style: const TextStyle(
                                  color: Color(0xFF8D6748),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.event, color: const Color(0xFF8D6748), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${_events.length} events',
                                style: const TextStyle(
                                  color: Color(0xFF8D6748),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildJoinLeaveButton(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _events.isEmpty && !_isDialogOpen
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        size: 64,
                                        color: Color(0xFF8D6748),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No events scheduled',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFF8D6748),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Events will appear here when they are created.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF8D6748),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                                  itemCount: _events.length,
                                  itemBuilder: (context, index) => _buildEventCard(_events[index]),
                                ),
                          _members.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 64,
                                        color: Color(0xFF8D6748),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No members yet',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFF8D6748),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Members will appear here when they join.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF8D6748),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                                  itemCount: _members.length,
                                  itemBuilder: (context, index) => _buildMemberCard(_members[index]),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _currentBookClub.isCreator
          ? FloatingActionButton(
              onPressed: _showCreateEventDialog,
              backgroundColor: const Color(0xFF8D6748),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
} 