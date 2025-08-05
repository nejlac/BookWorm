import 'dart:io';
import 'package:bookworm_mobile/model/author.dart';
import 'package:bookworm_mobile/model/genre.dart';
import 'package:bookworm_mobile/providers/book_provider.dart';
import 'package:bookworm_mobile/providers/author_provider.dart';
import 'package:bookworm_mobile/providers/genre_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:bookworm_mobile/screens/add_author.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({Key? key}) : super(key: key);

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _publicationYearController = TextEditingController();
  final TextEditingController _pageCountController = TextEditingController();

  Author? _selectedAuthor;
  List<Genre> _allGenres = [];
  List<Genre> _selectedGenres = [];
  List<Author> _allAuthors = [];
  File? _selectedImageFile;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final authorProvider = Provider.of<AuthorProvider>(context, listen: false);
      final genreProvider = Provider.of<GenreProvider>(context, listen: false);
      final authors = await authorProvider.getAllAuthors();
      final genres = await genreProvider.getAllGenres();
      setState(() {
        _allAuthors = authors;
        _allGenres = genres;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
      allowMultiple: false,
      withData: false,
    );
    if (result != null && result.files.single.path != null) {
      final pickedFile = File(result.files.single.path!);
      try {
        
        setState(() {
          _selectedImageFile = pickedFile;
        });
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF8D6E63)),
                SizedBox(width: 8),
                Text('Invalid Image'),
              ],
            ),
            content: Text(
              'The selected file could not be loaded as an image.\nPlease choose a valid image file (JPG, PNG, GIF, BMP, or WEBP).',
              style: TextStyle(fontSize: 15),
            ),
            backgroundColor: Color(0xFFFFF8E1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              TextButton(
                child: Text('OK', style: TextStyle(color: Color(0xFF8D6E63))),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
    });
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAuthor == null) {
      _showSnackBar('Please select an author.', isError: true);
      return;
    }
    if (_selectedGenres.isEmpty) {
      _showSnackBar('Select at least one genre.', isError: true);
      return;
    }
    setState(() { _isSaving = true; });
    try {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      final title = _titleController.text.trim();
      final authorId = _selectedAuthor!.id;
     
      final exists = await bookProvider.existsWithTitleAndAuthor(title, authorId);
      if (exists) {
        _showSnackBar('A book with this title and author already exists! Please choose a different title or author.', isError: true);
        setState(() { _isSaving = false; });
        return;
      }
      final request = {
        'title': title,
        'authorId': authorId,
        'description': _descriptionController.text.trim(),
        'publicationYear': int.tryParse(_publicationYearController.text.trim()) ?? 0,
        'pageCount': int.tryParse(_pageCountController.text.trim()) ?? 0,
        'genreIds': _selectedGenres.map((g) => g.id).toList(),
      };
      try {
        await bookProvider.insertWithCover(request, _selectedImageFile);
        _showSnackBar('Book added successfully! Admin needs to accept your book so others can see it too.', isError: false);
        Navigator.of(context).pop(true);
      } catch (e) {
        final errorMsg = e.toString().toLowerCase();
        if (errorMsg.contains('already exists') || errorMsg.contains('duplicate')) {
          _showSnackBar('A book with this title and author already exists! Please choose a different title or author.', isError: true);
        } else if (errorMsg.contains('400')) {
          _showSnackBar('Invalid data or duplicate book. Please check your input.', isError: true);
        } else {
          _showSnackBar('Failed to add book: $e', isError: true);
        }
      }
    } finally {
      setState(() { _isSaving = false; });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error : Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book'),
        backgroundColor: const Color(0xFF8D6748),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Book Information', Icons.book),
                    const SizedBox(height: 16),
                    
                    if (_selectedImageFile != null) _buildImagePreview(),
                    _buildImagePickerButton(),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration('📖 Title', Icons.title),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Title is required';
                        if (val.length > 255) return 'Title must be at most 255 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                   
                    Row(
                      children: [
                        Expanded(
                          child: DropdownSearch<Author>(
                            items: _allAuthors,
                            itemAsString: (author) => author.name,
                            selectedItem: _selectedAuthor,
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: _inputDecoration('✍️ Author', Icons.person),
                            ),
                            popupProps: PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  labelText: 'Search author',
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            onChanged: (author) {
                              setState(() {
                                _selectedAuthor = author;
                              });
                            },
                            validator: (author) {
                              if (author == null) {
                                return 'Please select an author';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Author', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8D6748),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddAuthorScreen(),
                              ),
                            );
                            if (result == true) {
                              final authorProvider = Provider.of<AuthorProvider>(context, listen: false);
                              final loadedAuthors = await authorProvider.getAllAuthors();
                              setState(() {
                                _allAuthors = loadedAuthors;
                              });
                              final newAuthor = _allAuthors.reduce((a, b) => a.id > b.id ? a : b);
                              setState(() {
                                _selectedAuthor = newAuthor;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _inputDecoration('📝 Description', Icons.description),
                      maxLines: 3,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Description is required';
                        if (val.length > 1000) return 'Description must be at most 1000 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildGenresChips(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _publicationYearController,
                            decoration: _inputDecoration('📅 Publication Year', Icons.calendar_today),
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Publication year is required';
                              final year = int.tryParse(val);
                              if (year == null) return 'Invalid year';
                              if (year > DateTime.now().year) return 'Year cannot be in the future';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _pageCountController,
                            decoration: _inputDecoration('📄 Pages', Icons.pages),
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Page count is required';
                              final count = int.tryParse(val);
                              if (count == null) return 'Invalid page count';
                              if (count <= 0) return 'Page count must be positive';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D6E63),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isSaving)
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(right: 12),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            Icon(_isSaving ? Icons.hourglass_empty : Icons.save, size: 20),
                            const SizedBox(width: 8),
                            Text(_isSaving ? 'Saving...' : 'Add Book',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40), 
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF8D6E63),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF8D6E63)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.brown.withOpacity(0.03),
      labelStyle: const TextStyle(
        color: Color(0xFF8D6E63),
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildGenresChips() {
    return InputDecorator(
      decoration: _inputDecoration('🏷️ Genres', Icons.category),
      child: Wrap(
        spacing: 8.0,
        children: _allGenres.map((genre) {
          final isSelected = _selectedGenres.contains(genre);
          return FilterChip(
            label: Text(genre.name),
            selected: isSelected,
            selectedColor: const Color(0xFFD7CCC8).withOpacity(0.3),
            checkmarkColor: const Color(0xFF8D6E63),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedGenres.add(genre);
                } else {
                  _selectedGenres.remove(genre);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImagePickerButton() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.add_photo_alternate, size: 16),
          label: const Text('Select Cover Image', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8D6E63),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            minimumSize: const Size(0, 32),
          ),
        ),
        if (_selectedImageFile != null) ...[
          const SizedBox(width: 6),
          ElevatedButton.icon(
            onPressed: _removeImage,
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Clear', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              minimumSize: const Size(0, 32),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8D6E63).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedImageFile!,
            fit: BoxFit.cover,
            width: 140,
            height: 210,
          ),
        ),
      ),
    );
  }
}
