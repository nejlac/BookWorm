import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookworm_mobile/providers/reading_list_provider.dart';
import 'package:bookworm_mobile/providers/auth_provider.dart';
import 'package:bookworm_mobile/model/reading_list.dart';
import 'package:bookworm_mobile/model/reading_list_book.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:bookworm_mobile/providers/user_provider.dart';
import 'package:bookworm_mobile/providers/book_provider.dart';
import 'package:bookworm_mobile/model/user.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:bookworm_mobile/screens/list_details.dart';

class MyListsScreen extends StatefulWidget {
  final bool showAppBar;
  final User? targetUser; 
  
  const MyListsScreen({Key? key, this.showAppBar = false, this.targetUser}) : super(key: key);

  static bool shouldShowCreateDialog = false;

  @override
  State<MyListsScreen> createState() => _MyListsScreenState();
}

class _MyListsScreenState extends State<MyListsScreen> with WidgetsBindingObserver {
  List<ReadingList> _readingLists = [];
  bool _isLoading = true;
  bool _isCreating = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadReadingLists();
    
  
    if (MyListsScreen.shouldShowCreateDialog) {
      MyListsScreen.shouldShowCreateDialog = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        createNewList();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasInitialized) {
      // Refresh when returning to the app
      _loadReadingLists();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
    }
  }

  // Method to refresh reading lists when navigating back to this screen
  void refreshReadingLists() {
    print('refreshReadingLists called'); // Debug print
    if (mounted && !_isLoading) {
      print('Refreshing reading lists...'); // Debug print
      _loadReadingLists();
    } else {
      print('Not refreshing - mounted: $mounted, loading: $_isLoading'); // Debug print
    }
  }

  

  Future<void> _loadReadingLists() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ReadingListProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      User? targetUser;
      User? currentUser;
      
      final username = AuthProvider.username;
      if (username != null) {
        final userResult = await userProvider.get(filter: {'username': username, 'pageSize': 1});
        currentUser = userResult.items != null && userResult.items!.isNotEmpty ? userResult.items!.first : null;
      }
      
      if (widget.targetUser != null) {
        targetUser = widget.targetUser;
      } else {
        targetUser = currentUser;
      }
      
      if (targetUser == null) {
        setState(() {
          _readingLists = [];
          _isLoading = false;
        });
        return;
      }
      
     
      final lists = await provider.getUserReadingLists(targetUser.id);
      
      
      List<ReadingList> filteredLists = [];
      for (var list in lists) {
        if (targetUser.id == currentUser?.id) {
          
          filteredLists.add(list);
        } else {
       
          List<ReadingListBook> approvedBooks = [];
          for (var book in list.books) {
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
          
     
          final filteredList = ReadingList(
            id: list.id,
            userId: list.userId,
            userName: list.userName,
            name: list.name,
            description: list.description,
            isPublic: list.isPublic,
            createdAt: list.createdAt,
            coverImagePath: list.coverImagePath,
            books: approvedBooks,
          );
          filteredLists.add(filteredList);
        }
      }
      setState(() {
        _readingLists = filteredLists;
        _isLoading = false;
      });
    } catch (e) {
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
          
                String? nameError;
                String? descriptionError;
          
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
      
        if (!_canEditLists()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can only create lists for your own account'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
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
      appBar: widget.showAppBar ? AppBar(
        backgroundColor: const Color(0xFF8D6748),
        foregroundColor: Colors.white,
        elevation: 2,
        title: Text(
          widget.targetUser != null ? '${widget.targetUser!.firstName}\'s Library' : 'My Library',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ) : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8D6748)))
          : RefreshIndicator(
              onRefresh: _loadReadingLists,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDefaultLists(),
                  const SizedBox(height: 24),
                 
                  if (_hasCustomLists()) ...[
                    Text(
                      widget.targetUser != null ? '${widget.targetUser!.firstName}\'s custom lists' : 'My custom lists',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCustomLists(),
                  ],
                ],
              ),
              ),
            ),
      floatingActionButton: _canEditLists() ? FloatingActionButton(
        onPressed: createNewList,
        backgroundColor: const Color(0xFF8D6748),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ) : null,
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
        title: Row(
          children: [
            Text(
              list.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4E342E),
              ),
            ),
            if (!_isCustomList(list))
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.lock,
                  size: 16,
                  color: Color(0xFF8D6748),
                ),
              ),
          ],
        ),
        subtitle: Text(
          '${list.bookCount} books',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: _canEditLists() ? PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Color(0xFF8D6E63)),
          onSelected: (value) => _handleListAction(value, list),
          itemBuilder: (context) => [
            if (_isCustomList(list))
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
        ) : null,
        onTap: () => _navigateToListDetails(list),
      ),
    );
  }

  Widget _buildListCover(ReadingList list) {
   
    
    String? imageUrl;
  
    if (list.coverImagePath != null && list.coverImagePath!.isNotEmpty) {
      imageUrl = _buildImageUrl(list.coverImagePath!);
      
    }

    else if (list.books.isNotEmpty && list.books.first.coverImagePath != null) {
      imageUrl = _buildImageUrl(list.books.first.coverImagePath!);
     
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

  bool _canEditLists() {
   
    if (widget.targetUser == null) return true;
    
    final username = AuthProvider.username;
    if (username == null) return false;
    
    return widget.targetUser!.username == username;
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

  Future<void> _editList(ReadingList list) async {
    if (!_canEditLists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only edit your own lists'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
   
    if (!_isCustomList(list)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Default lists cannot be edited'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final nameController = TextEditingController(text: list.name);
    final descriptionController = TextEditingController(text: list.description ?? '');
    File? selectedImage;
    String? currentImagePath = list.coverImagePath;
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Reading List'),
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
                      border: Border.all(color: const Color(0xFF8D6E63)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else if (currentImagePath != null && currentImagePath!.isNotEmpty)
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF8D6E63)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _buildImageUrl(currentImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF8D6E63),
                            child: const Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 32,
                            ),
                          );
                        },
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
                        currentImagePath = null; 
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: Text(selectedImage != null || currentImagePath != null ? 'Change Image' : 'Add Cover Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D6E63),
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
               
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
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
                
              
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
             
                String? nameError;
                String? descriptionError;
                
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
               
                Navigator.of(context).pop({
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'image': selectedImage,
                  'currentImagePath': currentImagePath,
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      try {
        setState(() {
          _isCreating = true;
        });

        final provider = Provider.of<ReadingListProvider>(context, listen: false);
        
        final updateData = {
          'name': result['name'],
          'description': result['description'],
        };

        final updatedList = await provider.update(list.id, updateData);
        
                 if (updatedList != null) {
          
           if (result['image'] != null) {
             final updatedListWithImage = await provider.uploadCover(updatedList.id, result['image']);
             if (updatedListWithImage != null) {
               setState(() {
                 final index = _readingLists.indexWhere((l) => l.id == list.id);
                 if (index != -1) {
                   _readingLists[index] = updatedListWithImage;
                 }
               });
             } else {
              
               setState(() {
                 final index = _readingLists.indexWhere((l) => l.id == list.id);
                 if (index != -1) {
                   _readingLists[index] = updatedList;
                 }
               });
             }
           } else {
           
             setState(() {
               final index = _readingLists.indexWhere((l) => l.id == list.id);
               if (index != -1) {
                 _readingLists[index] = updatedList;
               }
             });
           }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('List updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update list'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
      
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating list: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _deleteList(ReadingList list) async {
  
    if (!_canEditLists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only delete your own lists'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
   
    if (!_isCustomList(list)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Default lists cannot be deleted'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
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

  void _navigateToListDetails(ReadingList list) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListDetailsScreen(readingList: list),
      ),
    );
    
    // Always refresh when returning from list details, regardless of result
    if (mounted && !_isLoading) {
      _loadReadingLists();
    }
  }
} 