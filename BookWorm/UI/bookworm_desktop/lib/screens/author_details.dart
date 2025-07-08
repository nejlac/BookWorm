import 'package:bookworm_desktop/layouts/master_screen.dart';
import 'package:bookworm_desktop/model/author.dart';
import 'package:bookworm_desktop/model/country.dart';
import 'package:bookworm_desktop/providers/author_provider.dart';
import 'package:bookworm_desktop/providers/country_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:bookworm_desktop/providers/base_provider.dart';

class AuthorDetails extends StatefulWidget {
  final Author? author;
  final bool isEditMode;
  final bool isAddMode;
  const AuthorDetails({Key? key, this.author, this.isEditMode = false, this.isAddMode = false}) : super(key: key);

  @override
  State<AuthorDetails> createState() => _AuthorDetailsState();
}

class _AuthorDetailsState extends State<AuthorDetails> {
  final formKey = GlobalKey<FormBuilderState>();
  late AuthorProvider authorProvider;
  late CountryProvider countryProvider;
  List<Country> countries = [];
  Country? selectedCountry;
  File? _selectedImageFile;
  String? _existingPhotoUrl;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    authorProvider = Provider.of<AuthorProvider>(context, listen: false);
    countryProvider = Provider.of<CountryProvider>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    await countryProvider.fetchCountries();
    setState(() {
      countries = countryProvider.countries;
      if (widget.author != null && widget.author!.countryId != null) {
        selectedCountry = countries.firstWhere(
          (c) => c.id == widget.author!.countryId,
          orElse: () => countries.isNotEmpty ? countries.first : Country(id: -1, name: 'Unknown'),
        );
      } else {
        selectedCountry = countries.isNotEmpty ? countries.first : Country(id: -1, name: 'Unknown');
      }
      _existingPhotoUrl = widget.author?.photoUrl;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('[AuthorDetails] build() called');
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return MasterScreen(
      title: widget.isAddMode
          ? "Add Author"
          : widget.isEditMode
              ? "Edit Author"
              : "Author Details",
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          margin: EdgeInsets.symmetric(vertical: 32, horizontal: 12),
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.08),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(color: Color(0xFFD7CCC8).withOpacity(0.5)),
          ),
          child: SingleChildScrollView(
            child: FormBuilder(
              key: formKey,
              initialValue: {
                'name': widget.author?.name ?? '',
                'biography': widget.author?.biography ?? '',
                'dateOfBirth': widget.author?.dateOfBirth,
                'dateOfDeath': widget.author?.dateOfDeath,
                'country': selectedCountry,
                'photoUrl': widget.author?.photoUrl ?? '',
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8),
                  _buildPhotoSection(),
                  SizedBox(height: 18),
                  Text(
                    widget.author?.name ?? (widget.isAddMode ? "New Author" : ""),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4E342E),
                      fontFamily: 'Literata',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 18),
                  FormBuilderTextField(
                    name: 'name',
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.person, color: Color(0xFF8D6748)),
                      filled: true,
                      fillColor: Color(0xFFFFF8E1),
                    ),
                    readOnly: !(widget.isEditMode || widget.isAddMode),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Name is required';
                      return null;
                    },
                  ),
                  SizedBox(height: 14),
                  FormBuilderTextField(
                    name: 'biography',
                    decoration: InputDecoration(
                      labelText: 'Biography',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.menu_book, color: Color(0xFF8D6748)),
                      filled: true,
                      fillColor: Color(0xFFFFF8E1),
                    ),
                    maxLines: 4,
                    readOnly: !(widget.isEditMode || widget.isAddMode),
                  ),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderDateTimePicker(
                          name: 'dateOfBirth',
                          inputType: InputType.date,
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.cake, color: Color(0xFF8D6748)),
                            filled: true,
                            fillColor: Color(0xFFFFF8E1),
                          ),
                          enabled: widget.isEditMode || widget.isAddMode,
                          validator: (val) {
                            if (val == null) return 'Date of birth is required';
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: FormBuilderDateTimePicker(
                          name: 'dateOfDeath',
                          inputType: InputType.date,
                          decoration: InputDecoration(
                            labelText: 'Date of Death',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                           
                            filled: true,
                            fillColor: Color(0xFFFFF8E1),
                          ),
                          enabled: widget.isEditMode || widget.isAddMode,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),
                  FormBuilderDropdown<Country>(
                    name: 'country',
                    decoration: InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.flag, color: Color(0xFF8D6748)),
                      filled: true,
                      fillColor: Color(0xFFFFF8E1),
                    ),
                    items: countries
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name),
                            ))
                        .toList(),
                    initialValue: selectedCountry,
                    enabled: widget.isEditMode || widget.isAddMode,
                    validator: (val) {
                      if (val == null) return 'Country is required';
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  if (widget.isEditMode || widget.isAddMode)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: isSaving ? null : _saveAuthor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8D6748),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: isSaving
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(widget.isAddMode ? 'Add Author' : 'Save Changes'),
                        ),
                        SizedBox(width: 24),
                        OutlinedButton(
                          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF8D6748),
                            side: BorderSide(color: Color(0xFF8D6748)),
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  if (!widget.isEditMode && !widget.isAddMode && widget.author != null && widget.author!.authorState != 'Accepted')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: widget.author!.authorState == 'Submitted' || widget.author!.authorState == 'Declined'
                              ? () async {
                                  try {
                                    await Provider.of<AuthorProvider>(context, listen: false).accept(widget.author!.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.white),
                                            SizedBox(width: 12),
                                            Text('Author accepted!'),
                                          ],
                                        ),
                                        backgroundColor: Color(0xFF4CAF50),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                    Navigator.of(context).pop(true);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.error, color: Colors.white),
                                            SizedBox(width: 12),
                                            Text('Failed to accept author: \\${e.toString()}'),
                                          ],
                                        ),
                                        backgroundColor: Color(0xFFF44336),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          icon: Icon(Icons.check, color: Colors.white),
                          label: Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                        ),
                        SizedBox(width: 24),
                        ElevatedButton.icon(
                          onPressed: widget.author!.authorState == 'Submitted'
                              ? () async {
                                  try {
                                    await Provider.of<AuthorProvider>(context, listen: false).decline(widget.author!.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.cancel, color: Colors.white),
                                            SizedBox(width: 12),
                                            Text('Author declined!'),
                                          ],
                                        ),
                                        backgroundColor: Color(0xFFF44336),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                    Navigator.of(context).pop(true);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.error, color: Colors.white),
                                            SizedBox(width: 12),
                                            Text('Failed to decline author: \\${e.toString()}'),
                                          ],
                                        ),
                                        backgroundColor: Color(0xFFF44336),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          icon: Icon(Icons.cancel, color: Colors.white),
                          label: Text('Decline'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFC62828),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
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

  Widget _buildPhotoSection() {
    final hasImage = _selectedImageFile != null || (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty);
    String? imageUrl;
    if (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty) {
      if (_existingPhotoUrl!.startsWith('http')) {
        imageUrl = _existingPhotoUrl;
      } else {
        imageUrl = 'https://localhost:7031/${_existingPhotoUrl}';
      }
      print('[AuthorDetails] _existingPhotoUrl: \\${_existingPhotoUrl}');
      print('[AuthorDetails] imageUrl: \\${imageUrl}');
    }
    return Center(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF8D6748).withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: hasImage
                  ? (_selectedImageFile != null
                      ? Image.file(_selectedImageFile!, width: 120, height: 120, fit: BoxFit.cover)
                      : (imageUrl != null
                          ? Image.network(
                              imageUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _cutePlaceholder(),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  width: 120,
                                  height: 120,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                            )
                          : _cutePlaceholder()))
                  : _cutePlaceholder(),
            ),
          ),
          if (widget.isEditMode || widget.isAddMode)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImageFile,
                    icon: Icon(Icons.photo_library),
                    label: Text('Pick Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8D6748),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (_selectedImageFile != null)
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.red),
                      tooltip: 'Remove selected image',
                      onPressed: () {
                        setState(() {
                          _selectedImageFile = null;
                        });
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _cutePlaceholder() {
    return Container(
      width: 120,
      height: 120,
      color: Color(0xFFFFE0B2),
      child: Center(
        child: Text(
          "📚",
          style: TextStyle(fontSize: 48),
        ),
      ),
    );
  }

  Future<void> _pickImageFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
      allowMultiple: false,
      withData: false,
    );
    if (result != null && result.files.single.path != null) {
      final pickedFile = File(result.files.single.path!);
      try {
        await decodeImageFromList(await pickedFile.readAsBytes());
        setState(() {
          _selectedImageFile = pickedFile;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Text('Invalid image file.'),
              ],
            ),
            backgroundColor: Color(0xFFF44336),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveAuthor() async {
    if (!formKey.currentState!.saveAndValidate()) return;
    setState(() { isSaving = true; });
    final formData = formKey.currentState!.value;
    try {
      final request = {
        "name": formData['name'],
        "biography": formData['biography'],
        "dateOfBirth": (formData['dateOfBirth'] is DateTime)
            ? (formData['dateOfBirth'] as DateTime).toIso8601String()
            : (formData['dateOfBirth']?.toString() ?? ''),
        "dateOfDeath": (formData['dateOfDeath'] is DateTime)
            ? (formData['dateOfDeath'] as DateTime).toIso8601String()
            : null,
        "countryId": (formData['country'] as Country).id,
        // TODO: handle photo upload if needed
      };
      if (widget.isAddMode) {
        final inserted = await authorProvider.insert(request);
        if (_selectedImageFile != null && inserted.id != null) {
          try {
            await authorProvider.uploadPhoto(inserted.id, _selectedImageFile!);
            // Fetch updated author to get new photoUrl
            final updated = await authorProvider.getById(inserted.id);
            setState(() {
              _existingPhotoUrl = updated.photoUrl;
              _selectedImageFile = null;
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Failed to upload author photo: \\${e.toString()}'),
                  ],
                ),
                backgroundColor: Color(0xFFF44336),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
          // Show success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text("Author added successfully!"),
                ],
              ),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else if (widget.isEditMode && widget.author != null) {
        await authorProvider.update(widget.author!.id, request);
        if (_selectedImageFile != null) {
          try {
            await authorProvider.uploadPhoto(widget.author!.id, _selectedImageFile!);
            // Fetch updated author to get new photoUrl
            final updated = await authorProvider.getById(widget.author!.id);
            setState(() {
              _existingPhotoUrl = updated.photoUrl;
              _selectedImageFile = null;
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Failed to upload author photo: \\${e.toString()}'),
                  ],
                ),
                backgroundColor: Color(0xFFF44336),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
          // Show success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text("Author updated successfully!"),
                ],
              ),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Failed to save author: ${e.toString()}'),
            ],
          ),
          backgroundColor: Color(0xFFF44336),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      setState(() { isSaving = false; });
    }
  }
} 