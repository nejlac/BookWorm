import 'dart:async';
import 'dart:io';
import 'package:bookworm_mobile/model/country.dart';
import 'package:bookworm_mobile/model/user.dart';
import 'package:bookworm_mobile/providers/auth_provider.dart';
import 'package:bookworm_mobile/providers/country_provider.dart';
import 'package:bookworm_mobile/providers/user_provider.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:bookworm_mobile/layouts/master_screen.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  User? user;
  bool isLoading = true;
  bool isSaving = false;
  List<Country> countries = [];
  Country? selectedCountry;
  File? _selectedImageFile;
  String? _existingPhotoUrl;
  String? usernameError;
  String? emailError;
  String? errorMsg;
  Timer? _usernameDebounceTimer;
  Timer? _emailDebounceTimer;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final countryProvider = Provider.of<CountryProvider>(context, listen: false);
      final username = AuthProvider.username;
      
      
      if (username == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      
      await countryProvider.fetchCountries();
      
      final result = await userProvider.get(filter: {'username': username, 'pageSize': 1});
      
      if (mounted) {
        setState(() {
          user = result.items != null && result.items!.isNotEmpty ? result.items!.first : null;
          countries = countryProvider.countries;
          
          
          if (user != null) {
            firstNameController.text = user!.firstName;
            lastNameController.text = user!.lastName;
            usernameController.text = user!.username;
            emailController.text = user!.email;
            phoneController.text = user!.phoneNumber;
            ageController.text = user!.age.toString();
            
            
            selectedCountry = countries.firstWhere((c) => c.id == user!.countryId, orElse: () => countries.first);
            
            _existingPhotoUrl = user!.photoUrl;
          } else {
          }
          
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String? _getUserImageUrl() {
    final hasImage = _selectedImageFile != null || (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty);
    if (_selectedImageFile != null) return _selectedImageFile!.path;
    if (!hasImage) return null;
    if (_existingPhotoUrl!.startsWith('http')) {
      return _existingPhotoUrl!;
    } else {
      String base = BaseProvider.baseUrl ?? '';
      if (base.endsWith('/api/')) {
        base = base.substring(0, base.length - 5);
      }
      return '$base/${_existingPhotoUrl}';
    }
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
      
      if (users.items == null || users.items!.isEmpty) {
        return false; // Username doesn't exist
      }
      
      // If it's the same user, allow it
      if (user != null && users.items!.first.id == user!.id) {
        return false; // Same user, allow the username
      }
      
      return true; // Username exists and belongs to another user
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
      
      if (users.items == null || users.items!.isEmpty) {
        return false; // Email doesn't exist
      }
      
      // If it's the same user, allow it
      if (user != null && users.items!.first.id == user!.id) {
        return false; // Same user, allow the email
      }
      
      return true; // Email exists and belongs to another user
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { isSaving = true; usernameError = null; emailError = null; errorMsg = null; });
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final country = selectedCountry;
      if (country == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a country.')),
        );
        setState(() { isSaving = false; });
        return;
      }
      final request = {
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "username": usernameController.text.trim(),
        "email": emailController.text.trim(),
        "phoneNumber": phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        "age": int.tryParse(ageController.text.trim()) ?? 0,
        "countryId": country.id,
        "photoUrl": _existingPhotoUrl,
        "roleIds": [2], 
      };
      await userProvider.update(user!.id, request);
      
      final newUsername = usernameController.text.trim();
      if (AuthProvider.username != newUsername) {
        AuthProvider.updateUsername(newUsername);
      }
      
      if (_selectedImageFile != null) {
        await userProvider.uploadPhoto(user!.id, _selectedImageFile!);
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
                  const Icon(Icons.check_circle, color: Color(0xFF8D6748), size: 54),
                  const SizedBox(height: 18),
                  const Text(
                    'Profile updated!',
                    style: TextStyle(
                      fontFamily: 'Literata',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF8D6748),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your changes have been saved.',
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
                        backgroundColor: const Color(0xFF8D6748),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MasterScreen(initialIndex: 4)),
                      ),
                      child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
          } catch (e) {
        String errorMsg = e.toString();
        
        if (errorMsg.contains('already exists')) {
          if (errorMsg.contains('username')) {
            errorMsg = 'A user with this username already exists.';
          } else if (errorMsg.contains('email')) {
            errorMsg = 'A user with this email already exists.';
          } else {
            errorMsg = 'This information already exists in our system.';
          }
        } else if (errorMsg.contains('400') || errorMsg.contains('Bad Request')) {
          errorMsg = 'Please check your input and try again.';
        } else if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
          errorMsg = 'You are not authorized to perform this action.';
        } else if (errorMsg.contains('500') || errorMsg.contains('Internal Server Error')) {
          errorMsg = 'Server error. Please try again later.';
        } else if (errorMsg.contains('SocketException') || errorMsg.contains('Connection')) {
          errorMsg = 'Network error. Please check your connection and try again.';
        } else if (errorMsg.contains('TimeoutException')) {
          errorMsg = 'Request timeout. Please try again.';
        }
        
        setState(() { errorMsg = errorMsg; });
      } finally {
      setState(() { isSaving = false; });
    }
  }

  @override
  void dispose() {
    _usernameDebounceTimer?.cancel();
    _emailDebounceTimer?.cancel();
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6E3B4),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF8E1),
          elevation: 0,
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Color(0xFF8D6748)),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontFamily: 'Literata',
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Color(0xFF5D4037),
            ),
          ),
          centerTitle: false,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8D6748)),
              ),
              SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: TextStyle(
                  color: Color(0xFF5D4037),
                  fontSize: 16,
                  fontFamily: 'Literata',
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF6E3B4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Color(0xFF8D6748)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: 'Literata',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF5D4037),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                 
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFFE0C9A6),
                        backgroundImage: _getUserImageUrl() != null && _selectedImageFile == null
                            ? NetworkImage(_getUserImageUrl()!)
                            : _selectedImageFile != null
                                ? FileImage(_selectedImageFile!) as ImageProvider
                                : null,
                        child: (_getUserImageUrl() == null && _selectedImageFile == null)
                            ? const Icon(Icons.person, size: 70, color: Color(0xFF8D6748))
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImageFile,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF8D6748),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          errorMsg!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                  TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF8D6748)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFFFF8E1),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'First name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF8D6748)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFFFF8E1),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Last name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.account_circle, color: Color(0xFF8D6748)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFFFF8E1),
                    ),
                    onChanged: (value) {
                      _usernameDebounceTimer?.cancel();
                      if (value.trim().isNotEmpty) {
                        _usernameDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
                          final exists = await _checkUsernameExists(value.trim());
                          if (mounted) {
                            setState(() {
                              usernameError = exists ? 'A user with the username "${value.trim()}" already exists.' : null;
                            });
                            // Trigger form validation immediately
                            _formKey.currentState?.validate();
                          }
                        });
                      } else {
                        setState(() {
                          usernameError = null;
                        });
                        // Trigger form validation immediately
                        _formKey.currentState?.validate();
                      }
                    },
                                          validator: (val) {
                        if (val == null || val.isEmpty) return 'Username is required';
                        if (usernameError != null) return usernameError;
                        return null;
                      },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF8D6748)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFFFF8E1),
                    ),
                    onChanged: (value) {
                      _emailDebounceTimer?.cancel();
                      if (value.trim().isNotEmpty) {
                        _emailDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
                          final exists = await _checkEmailExists(value.trim());
                          if (mounted) {
                            setState(() {
                              emailError = exists ? 'A user with the email "${value.trim()}" already exists.' : null;
                            });
                            // Trigger form validation immediately
                            _formKey.currentState?.validate();
                          }
                        });
                      } else {
                        setState(() {
                          emailError = null;
                        });
                        // Trigger form validation immediately
                        _formKey.currentState?.validate();
                      }
                    },
                                          validator: (val) {
                        if (val == null || val.isEmpty) return 'Email is required';
                        if (val.length > 100) return 'Email must be at most 100 characters';
                        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                        if (!emailRegex.hasMatch(val)) return 'Enter a valid email address';
                        if (emailError != null) return emailError;
                        return null;
                      },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone, color: Color(0xFF8D6748)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFFFF8E1),
                    ),
                    validator: (val) {
                      if (val == null || val.toString().trim().isEmpty) {
                        return null;
                      }
                      final trimmedVal = val.toString().trim();
                      if (trimmedVal.length > 20) {
                        return 'Phone number must not exceed 20 characters';
                      }
                      final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{7,20}');
                      if (!phoneRegex.hasMatch(trimmedVal)) {
                        return 'Invalid phone number format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: ageController,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      prefixIcon: const Icon(Icons.cake, color: Color(0xFF8D6748)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFFFF8E1),
                    ),
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
                        prefixIcon: Icon(Icons.flag, color: Color(0xFF8D6748)),
                        filled: true,
                        fillColor: Color(0xFFFFF8E1),
                      ),
                    ),
                    validator: (value) => value == null ? 'Country is required' : null,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8D6748),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}