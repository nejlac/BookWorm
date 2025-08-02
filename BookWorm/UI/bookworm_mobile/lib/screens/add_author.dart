import 'dart:io';
import 'package:bookworm_mobile/model/country.dart';
import 'package:bookworm_mobile/providers/author_provider.dart';
import 'package:bookworm_mobile/providers/country_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AddAuthorScreen extends StatefulWidget {
  const AddAuthorScreen({Key? key}) : super(key: key);

  @override
  State<AddAuthorScreen> createState() => _AddAuthorScreenState();
}

class _AddAuthorScreenState extends State<AddAuthorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _biographyController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _dateOfDeathController = TextEditingController();

  List<Country> _countries = [];
  Country? _selectedCountry;
  File? _selectedImageFile;
  bool _isSaving = false;
  bool _isLoading = true;
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedDateOfDeath;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final countryProvider = Provider.of<CountryProvider>(context, listen: false);
      await countryProvider.fetchCountries();
      setState(() {
        _countries = countryProvider.countries;
        if (_countries.isNotEmpty) {
          _selectedCountry = _countries.first;
        }
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
        final bytes = await pickedFile.readAsBytes();
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

  Future<void> _selectDate(BuildContext context, bool isDateOfBirth) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDateOfBirth ? DateTime.now().subtract(Duration(days: 365 * 25)) : DateTime.now(),
      firstDate: DateTime(1),
      lastDate: isDateOfBirth ? DateTime.now() : DateTime.now().add(Duration(days: 365 * 10)),
      cancelText: isDateOfBirth ? null : 'Clear', // Allow clearing for optional date of death
    );
    if (picked != null) {
      setState(() {
        if (isDateOfBirth) {
          _selectedDateOfBirth = picked;
          _dateOfBirthController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        } else {
          _selectedDateOfDeath = picked;
          _dateOfDeathController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        }
      });
    } else if (!isDateOfBirth) {
      // Clear the date of death if user cancels
      setState(() {
        _selectedDateOfDeath = null;
        _dateOfDeathController.clear();
      });
    }
  }

  Future<void> _saveAuthor() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCountry == null) {
      _showSnackBar('Please select a country.', isError: true);
      return;
    }
    if (_selectedDateOfBirth == null) {
      _showSnackBar('Please select date of birth.', isError: true);
      return;
    }

    // Frontend validation matching backend rules
    final validationErrors = _validateAuthorData();
    if (validationErrors.isNotEmpty) {
      _showSnackBar(validationErrors.first, isError: true);
      return;
    }

    setState(() { _isSaving = true; });

    try {
      final authorProvider = Provider.of<AuthorProvider>(context, listen: false);
      final name = _nameController.text.trim();
      
      // Duplicate check
      final exists = await authorProvider.existsWithNameAndDateOfBirth(name, _selectedDateOfBirth!);
      if (exists) {
        _showSnackBar('An author with this name and date of birth already exists!', isError: true);
        setState(() { _isSaving = false; });
        return;
      }

      final request = {
        'name': name,
        'biography': _biographyController.text.trim(),
        'dateOfBirth': _selectedDateOfBirth!.toIso8601String(),
        'dateOfDeath': _selectedDateOfDeath?.toIso8601String(),
        'countryId': _selectedCountry!.id,
      };

      final inserted = await authorProvider.insert(request);
      
      if (_selectedImageFile != null && inserted.id != null) {
        try {
          await authorProvider.uploadPhoto(inserted.id, _selectedImageFile!);
        } catch (e) {
          print('Failed to upload author photo: $e');
          
        }
      }

      _showSnackBar('Author added successfully! Admin needs to accept your author so others can see it too.', isError: false);
      Navigator.of(context).pop(true);
    } catch (e) {
      _showSnackBar('Failed to add author: $e', isError: true);
    } finally {
      setState(() { _isSaving = false; });
    }
  }

  List<String> _validateAuthorData() {
    final errors = <String>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Name validation
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      errors.add('Name is required.');
    } else if (name.length > 255) {
      errors.add('Name must not exceed 255 characters.');
    }

    // Biography validation
    final biography = _biographyController.text.trim();
    if (biography.isEmpty) {
      errors.add('Biography is required.');
    } else if (biography.length > 1000) {
      errors.add('Biography must not exceed 1000 characters.');
    }

    // Date of birth validation
    if (_selectedDateOfBirth == null) {
      errors.add('Date of birth is required.');
    } else if (_selectedDateOfBirth!.isAfter(today)) {
      errors.add('Date of birth cannot be in the future.');
    }

    // Date of death validation
    if (_selectedDateOfDeath != null) {
      if (_selectedDateOfDeath!.isAfter(today)) {
        errors.add('Date of death cannot be in the future.');
      }
      
      if (_selectedDateOfBirth != null && _selectedDateOfDeath!.isBefore(_selectedDateOfBirth!)) {
        errors.add('Date of death cannot be before date of birth.');
      }
    }

    // Country validation
    if (_selectedCountry == null) {
      errors.add('Country is required.');
    }

    return errors;
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
        title: const Text('Add Author'),
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
                    _buildSectionTitle('Author Information', Icons.person),
                    const SizedBox(height: 16),
                    
                    // Image picker at the top
                    if (_selectedImageFile != null) _buildImagePreview(),
                    _buildImagePickerButton(),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('✍️ Name', Icons.person),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Name is required';
                        if (val.trim().length > 255) return 'Name must not exceed 255 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _biographyController,
                      decoration: _inputDecoration('📖 Biography', Icons.menu_book),
                      maxLines: 4,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Biography is required';
                        if (val.trim().length > 1000) return 'Biography must not exceed 1000 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dateOfBirthController,
                            decoration: _inputDecoration(' Date of Birth', Icons.cake),
                            readOnly: true,
                            onTap: () => _selectDate(context, true),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Date of birth is required';
                              if (_selectedDateOfBirth != null) {
                                final now = DateTime.now();
                                final today = DateTime(now.year, now.month, now.day);
                                if (_selectedDateOfBirth!.isAfter(today)) {
                                  return 'Date of birth cannot be in the future';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _dateOfDeathController,
                            decoration: _inputDecoration(' Date of Death (Optional)', Icons.event).copyWith(
                              suffixIcon: _dateOfDeathController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _selectedDateOfDeath = null;
                                          _dateOfDeathController.clear();
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            readOnly: true,
                            onTap: () => _selectDate(context, false),
                            validator: (val) {
                              if (_selectedDateOfDeath != null) {
                                final now = DateTime.now();
                                final today = DateTime(now.year, now.month, now.day);
                                if (_selectedDateOfDeath!.isAfter(today)) {
                                  return 'Date of death cannot be in the future';
                                }
                                if (_selectedDateOfBirth != null && _selectedDateOfDeath!.isBefore(_selectedDateOfBirth!)) {
                                  return 'Date of death cannot be before date of birth';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownSearch<Country>(
                      items: _countries,
                      itemAsString: (country) => country.name,
                      selectedItem: _selectedCountry,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: _inputDecoration('🏳️ Country', Icons.flag),
                      ),
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: 'Search country',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      onChanged: (country) {
                        setState(() {
                          _selectedCountry = country;
                        });
                      },
                      validator: (country) {
                        if (country == null) {
                          return 'Please select a country';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAuthor,
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
                            Text(_isSaving ? 'Saving...' : 'Add Author',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40), // Extra padding at the bottom
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

  Widget _buildImagePickerButton() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.add_photo_alternate, size: 16),
          label: const Text('Select Author Photo', style: TextStyle(fontSize: 12)),
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
            width: 120,
            height: 120,
          ),
        ),
      ),
    );
  }
} 