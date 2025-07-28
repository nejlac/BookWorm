import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookworm_mobile/providers/reading_list_provider.dart';
import 'package:bookworm_mobile/providers/auth_provider.dart';
import 'package:bookworm_mobile/model/reading_list.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:bookworm_mobile/providers/user_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:bookworm_mobile/screens/list_details.dart';

class MyListsScreen extends StatefulWidget {
  const MyListsScreen({Key? key}) : super(key: key);

  static bool shouldShowCreateDialog = false;

  @override
  State<MyListsScreen> createState() => _MyListsScreenState();
}

class _MyListsScreenState extends State<MyListsScreen> {
  List<ReadingList> _readingLists = [];
  bool _isLoading = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadReadingLists();
    
    // Check if we should show the create dialog
    if (MyListsScreen.shouldShowCreateDialog) {
      MyListsScreen.shouldShowCreateDialog = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        createNewList();
      });
    }
  }

  Future<void> _loadReadingLists() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ReadingListProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final username = AuthProvider.username;
      
      if (username == null) {
        setState(() {
          _readingLists = [];
          _isLoading = false;
        });
        return;
      }
      
      // Get current user by username
      final userResult = await userProvider.get(filter: {'username': username, 'pageSize': 1});
      final currentUser = userResult.items != null && userResult.items!.isNotEmpty ? userResult.items!.first : null;
      
      if (currentUser == null) {
        setState(() {
          _readingLists = [];
          _isLoading = false;
        });
        return;
      }
      
      // Get reading lists for the current user
      final lists = await provider.getUserReadingLists(currentUser.id);
      
      // Debug: Print each list and its books
      print('=== DEBUG: Reading Lists Data ===');
      for (var list in lists) {
        print('List: ${list.name}');
        print('  - CoverImagePath: ${list.coverImagePath}');
        print('  - Books count: ${list.books.length}');
        for (var book in list.books) {
          print('    Book: ${book.title}');
          print('      - CoverImagePath: ${book.coverImagePath}');
        }
        print('---');
      }
      
      setState(() {
        _readingLists = lists;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reading lists: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> createNewList() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    File? selectedImage;
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Create New Reading List'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image picker section
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
                      setDialogState(() {
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
                
                // Name Field
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'List Name *',
                    border: OutlineInputBorder(),
                    hintText: 'Enter list name',
                  ),
                  maxLength: 100,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required.';
                    }
                    if (value.length > 100) {
                      return 'Name must not exceed 100 characters.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Description Field
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                    hintText: 'Enter list description',
                  ),
                  maxLength: 300,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required.';
                    }
                    if (value.length > 300) {
                      return 'Description must not exceed 300 characters.';
                    }
                    return null;
                  },
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
              onPressed: () {
                // Validate fields
                String? nameError;
                String? descriptionError;
                
                // Name validation
                if (nameController.text.trim().isEmpty) {
                  nameError = 'Name is required.';
                } else if (nameController.text.length > 100) {
                  nameError = 'Name must not exceed 100 characters.';
                }
                
                // Description validation
                if (descriptionController.text.trim().isEmpty) {
                  descriptionError = 'Description is required.';
                } else if (descriptionController.text.length > 300) {
                  descriptionError = 'Description must not exceed 300 characters.';
                }
                
                // Show validation errors if any
                if (nameError != null || descriptionError != null) {
                  String errorMessage = '';
                  if (nameError != null) errorMessage += nameError + '\n';
                  if (descriptionError != null) errorMessage += descriptionError;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage.trim()),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                // If validation passes, return the data
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
        setState(() {
          _isLoading = true;
        });

        final provider = Provider.of<ReadingListProvider>(context, listen: false);
        
        // Get current user ID
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final username = AuthProvider.username;
        
        if (username != null) {
          // Get the current user by username
          final userResult = await userProvider.get(filter: {'username': username, 'pageSize': 1});
          final currentUser = userResult.items != null && userResult.items!.isNotEmpty ? userResult.items!.first : null;
          
          if (currentUser != null) {
            // Create the reading list
            var newList = await provider.create({
              'userId': currentUser.id,
              'name': result['name'],
              'description': result['description'],
              'isPublic': true,
              'bookIds': [],
            });

            // Upload cover image if selected
            if (result['image'] != null) {
              final updatedList = await provider.uploadCover(newList.id, result['image']);
              if (updatedList != null) {
                newList = updatedList;
              }
            }

            setState(() {
              _readingLists.add(newList);
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Reading list created successfully!')),
            );
          } else {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('User not found'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Not logged in'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating reading list: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReadingLists,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Default lists section
                    _buildDefaultLists(),
                    SizedBox(height: 24),
                    
                    // Custom lists section
                    if (_hasCustomLists()) ...[
                      Text(
                        'My custom lists',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildCustomLists(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDefaultLists() {
    final defaultLists = _readingLists.where((list) => 
      list.name == 'Want to read' || 
      list.name == 'Currently reading' || 
      list.name == 'Read'
    ).toList();

    return Column(
      children: defaultLists.map((list) => _buildListCard(list)).toList(),
    );
  }

  Widget _buildCustomLists() {
    final customLists = _readingLists.where((list) => 
      list.name != 'Want to read' && 
      list.name != 'Currently reading' && 
      list.name != 'Read'
    ).toList();

    return Column(
      children: customLists.map((list) => _buildListCard(list)).toList(),
    );
  }

  Widget _buildListCard(ReadingList list) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF8D6E63).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: _buildListCover(list),
        ),
        title: Text(
          list.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4E342E),
          ),
        ),
        subtitle: Text(
          '${list.bookCount} books',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Color(0xFF8D6E63)),
          onSelected: (value) => _handleListAction(value, list),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            if (_isCustomList(list))
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
        onTap: () => _navigateToListDetails(list),
      ),
    );
  }

  Widget _buildListCover(ReadingList list) {
    print('Building cover for list: ${list.name}');
    print('List coverImagePath: ${list.coverImagePath}');
    print('List firstBookCoverUrl: ${list.firstBookCoverUrl}');
    print('List books count: ${list.books.length}');
    
    String? imageUrl;
    
    // First try to use the list's own cover image
    if (list.coverImagePath != null && list.coverImagePath!.isNotEmpty) {
      imageUrl = _buildImageUrl(list.coverImagePath!);
      print('Using list cover URL: $imageUrl');
    }
    // Fall back to the first book's cover
    else if (list.books.isNotEmpty && list.books.first.coverImagePath != null) {
      imageUrl = _buildImageUrl(list.books.first.coverImagePath!);
      print('Using book cover URL: $imageUrl');
    } else {
      print('No cover image available');
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading cover: $error');
                return _buildDefaultCover();
              },
            )
          : _buildDefaultCover(),
    );
  }

  Widget _buildDefaultCover() {
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

  bool _hasCustomLists() {
    return _readingLists.any((list) => 
      list.name != 'Want to read' && 
      list.name != 'Currently reading' && 
      list.name != 'Read'
    );
  }

  bool _isCustomList(ReadingList list) {
    return list.name != 'Want to read' && 
           list.name != 'Currently reading' && 
           list.name != 'Read';
  }

  void _handleListAction(String action, ReadingList list) {
    switch (action) {
      case 'edit':
        _editList(list);
        break;
      case 'delete':
        _deleteList(list);
        break;
    }
  }

  void _editList(ReadingList list) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit functionality coming soon!')),
    );
  }

  Future<void> _deleteList(ReadingList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete List'),
        content: Text('Are you sure you want to delete "${list.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = Provider.of<ReadingListProvider>(context, listen: false);
        final success = await provider.delete(list.id);
        
        if (success) {
          setState(() {
            _readingLists.removeWhere((l) => l.id == list.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('List deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete list'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting list: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToListDetails(ReadingList list) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListDetailsScreen(readingList: list),
      ),
    );
  }
} 