import 'dart:io';
import 'package:bookworm_mobile/layouts/master_screen.dart';
import 'package:bookworm_mobile/model/country.dart';
import 'package:bookworm_mobile/providers/country_provider.dart';
import 'package:bookworm_mobile/providers/user_provider.dart';
import 'package:bookworm_mobile/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart'; 
import 'dart:async';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  File? _selectedImageFile;
  bool isLoading = false;
  List<Country> countries = [];
  Country? selectedCountry;
  String? errorMsg;
  String? duplicateError;
  Timer? _usernameDebounceTimer;
  Timer? _emailDebounceTimer;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  @override
  void dispose() {
    _usernameDebounceTimer?.cancel();
    _emailDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    final provider = Provider.of<CountryProvider>(context, listen: false);
    await provider.fetchCountries();
    setState(() {
      countries = provider.countries;
      if (countries.isNotEmpty) {
        selectedCountry = countries.first;
      }
    });
  }

  Future<void> _pickImageFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
      allowMultiple: false,
      withData: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImageFile = File(result.files.single.path!);
      });
    }
  }

  Future<bool> _checkUsernameExists(String username) async {
    if (username.trim().isEmpty) return false;
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final filter = {
        'username': username.trim(),
        'pageSize': 1,
        'page': 0,
      };
      final users = await userProvider.get(filter: filter);
      return users.items != null && users.items!.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkEmailExists(String email) async {
    if (email.trim().isEmpty) return false;
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final filter = {
        'email': email.trim(),
        'pageSize': 1,
        'page': 0,
      };
      final users = await userProvider.get(filter: filter);
      return users.items != null && users.items!.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _register() async {
    if (!formKey.currentState!.saveAndValidate()) return;
    setState(() { isLoading = true; errorMsg = null; });
    final formData = formKey.currentState!.value;
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final country = selectedCountry;
      if (country == null) {
        setState(() { errorMsg = 'Please select a country.'; isLoading = false; });
        return;
      }
      final request = {
        "firstName": formData['firstName']?.toString().trim() ?? '',
        "lastName": formData['lastName']?.toString().trim() ?? '',
        "username": formData['username']?.toString().trim() ?? '',
        "email": formData['email']?.toString().trim() ?? '',
        "phoneNumber": formData['phoneNumber']?.toString().trim(),
        "age": int.tryParse(formData['age']?.toString() ?? '0') ?? 0,
        "countryId": country.id,
        "roleIds": [2], 
        "password": formData['password']?.toString(),
      };
      final user = await userProvider.insert(request);
      if (_selectedImageFile != null && user.id != 0) {
        await userProvider.uploadPhoto(user.id, _selectedImageFile!);
      }
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: const Color(0xFFFFF8E1),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_rounded, color: Color(0xFF8D6748), size: 54),
                  const SizedBox(height: 18),
                  const Text(
                    'Registration Successful!',
                    style: TextStyle(
                      fontFamily: 'Literata',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF8D6748),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Welcome to BookWorm!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 16,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8D6748),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MasterScreen()),
                      ),
                      child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() { errorMsg = e.toString(); });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: const Color(0xFF8D6748),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: FormBuilder(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (errorMsg != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                          ),
                        Center(
                          child: GestureDetector(
                            onTap: _pickImageFile,
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: const Color(0xFFFFE0B2),
                              backgroundImage: _selectedImageFile != null ? FileImage(_selectedImageFile!) : null,
                              child: _selectedImageFile == null ? const Icon(Icons.camera_alt, size: 36, color: Color(0xFF8D6748)) : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        FormBuilderTextField(
                          name: 'firstName',
                          decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                          validator: (val) {
                      if (val == null || val.isEmpty) return 'First name is required';
                      return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'lastName',
                          decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                          validator: (val) {
                      if (val == null || val.isEmpty) return 'Last name is required';
                      return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'username',
                          decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                          onChanged: (value) {
                            _usernameDebounceTimer?.cancel();
                            if (value != null && value.trim().isNotEmpty) {
                              _usernameDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
                                final exists = await _checkUsernameExists(value.trim());
                                if (mounted) {
                                  setState(() {
                                    duplicateError = exists ? 'A user with the username "${value.trim()}" already exists.' : null;
                                  });
                                }
                              });
                            } else {
                              setState(() {
                                duplicateError = null;
                              });
                            }
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Username is required';
                            if (duplicateError != null && duplicateError!.contains('username')) return duplicateError;
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'email',
                          decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                          onChanged: (value) {
                            _emailDebounceTimer?.cancel();
                            if (value != null && value.trim().isNotEmpty) {
                              _emailDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
                                final exists = await _checkEmailExists(value.trim());
                                if (mounted) {
                                  setState(() {
                                    duplicateError = exists ? 'A user with the email "${value.trim()}" already exists.' : null;
                                  });
                                }
                              });
                            } else {
                              setState(() {
                                duplicateError = null;
                              });
                            }
                          },
                          validator:  (val) {
                            if (val == null || val.isEmpty) return 'Email is required';
                            if (val.length > 100) return 'Email must be at most 100 characters';
                            final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            if (!emailRegex.hasMatch(val)) return 'Enter a valid email address';
                            if (duplicateError != null && duplicateError!.contains('email')) return duplicateError;
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'phoneNumber',
                          decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                           validator: (val) {
                     
                      if (val == null || val.toString().trim().isEmpty) {
                        return null;
                      }
                      
                   
                      final trimmedVal = val.toString().trim();
                      
                      if (trimmedVal.length > 20) {
                        return 'Phone number must not exceed 20 characters';
                      }
                      
                      
                      final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{7,20}$');
                      if (!phoneRegex.hasMatch(trimmedVal)) {
                        return 'Invalid phone number format';
                      }
                      
                      return null;
                    },
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'age',
                          decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Age is required';
                            final age = int.tryParse(val);
                            if (age == null) return 'Invalid age';
                            if (age < 13) return 'User must be older than 13';
                            if (age > 120) return 'Invalid age';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownSearch<Country>(
                          items: countries,
                          itemAsString: (c) => c.name,
                          selectedItem: selectedCountry,
                          onChanged: (value) => setState(() => selectedCountry = value),
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Country',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          validator: (value) => value == null ? 'Country is required' : null,
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'password',
                          decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                          obscureText: true,
                          validator:  (val) {
                              if (val == null || val.isEmpty) {
                                return 'Password is required';
                              }
                              if (val.length < 8) return 'Password must be at least 8 characters long.';
                              final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$');
                              if (!regex.hasMatch(val)) {
                                return 'Password must contain uppercase, lowercase, number, and special character.';
                              }
                              return null;
                            },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8D6748),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Register'),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
