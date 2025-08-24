import 'package:bookworm_desktop/model/country.dart';
import 'package:bookworm_desktop/model/user.dart';
import 'package:bookworm_desktop/providers/country_provider.dart';
import 'package:bookworm_desktop/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:bookworm_desktop/model/role.dart';
import 'package:bookworm_desktop/providers/role_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:bookworm_desktop/providers/base_provider.dart';

class UserDetails extends StatefulWidget {
  final User? user;
  final bool isEditMode;
  final bool isAddMode;
  const UserDetails({Key? key, this.user, this.isEditMode = false, this.isAddMode = false}) : super(key: key);

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final formKey = GlobalKey<FormBuilderState>();
  late UserProvider userProvider;
  late CountryProvider countryProvider;
  List<Country> countries = [];
  Country? selectedCountry;
  File? _selectedImageFile;
  String? _existingPhotoUrl;
  bool isLoading = true;
  bool isSaving = false;
  late RoleProvider roleProvider;
  List<Role> allRoles = [];
  List<Role> selectedRoles = [];
  bool rolesLoading = true;
  String? usernameError;
  String? emailError;
  bool showPasswordFields = false;
  String? passwordError;
  String? confirmPasswordError;
  
  
  Timer? _usernameDebounceTimer;
  Timer? _emailDebounceTimer;

  Future<bool> _checkUsernameExists(String username, int? excludeId) async {
    if (username.trim().isEmpty) return false;
    try {
      final filter = {
        'username': username.trim(),
        'pageSize': 1,
        'page': 0,
      };
      final users = await userProvider.get(filter: filter);
      if (users.items == null || users.items!.isEmpty) return false;
      if (excludeId != null) {
        return users.items!.any((user) => user.id != excludeId);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkEmailExists(String email, int? excludeId) async {
    if (email.trim().isEmpty) return false;
    try {
      final filter = {
        'email': email.trim(),
        'pageSize': 1,
        'page': 0,
      };
      final users = await userProvider.get(filter: filter);
      if (users.items == null || users.items!.isEmpty) return false;
      if (excludeId != null) {
        return users.items!.any((user) => user.id != excludeId);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    countryProvider = Provider.of<CountryProvider>(context, listen: false);
    roleProvider = Provider.of<RoleProvider>(context, listen: false);
    selectedRoles = widget.user?.roles ?? [];
    _loadData();
    _loadRoles();
  }

  @override
  void dispose() {
    _usernameDebounceTimer?.cancel();
    _emailDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final allCountries = await countryProvider.getAllCountriesForDropdown();
      setState(() {
        countries = allCountries;
        if (widget.user != null && widget.user!.countryId != null) {
          selectedCountry = countries.firstWhere(
            (c) => c.id == widget.user!.countryId,
            orElse: () => countries.isNotEmpty ? countries.first : Country(id: -1, name: 'Unknown'),
          );
        } else {
          selectedCountry = countries.isNotEmpty ? countries.first : Country(id: -1, name: 'Unknown');
        }
        _existingPhotoUrl = widget.user?.photoUrl;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        countries = [];
        selectedCountry = Country(id: -1, name: 'Unknown');
        _existingPhotoUrl = widget.user?.photoUrl;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load countries: '+e.toString())),
      );
    }
  }

  Future<void> _loadRoles() async {
    setState(() { rolesLoading = true; });
    try {
      final roles = await roleProvider.getAllRoles();
      setState(() {
        allRoles = roles;
        rolesLoading = false;
      });
    } catch (e) {
      setState(() { rolesLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load roles: '+e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.isAddMode ? 'Add User' : widget.isEditMode ? 'Edit User' : 'User Details'),
        backgroundColor: Color(0xFF8D6748),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
                        body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: FormBuilder(
              key: formKey,
              initialValue: {
                'firstName': widget.user?.firstName ?? '',
                'lastName': widget.user?.lastName ?? '',
                'username': widget.user?.username ?? '',
                'email': widget.user?.email ?? '',
                'phoneNumber': widget.user?.phoneNumber ?? '',
                      'age': (widget.user?.age ?? 0).toString(),
                      'lastLoginAt': widget.user?.lastLoginAt?.toString() ?? '',
                'country': selectedCountry,
                'photoUrl': widget.user?.photoUrl ?? '',
                      'roles': widget.user?.roles ?? [],
              },
              child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                        Text('User Information',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF4E342E)),
                    textAlign: TextAlign.center,
                  ),
                        Divider(height: 24, thickness: 1, color: Color(0xFF8D6748).withOpacity(0.2)),
                  SizedBox(height: 8),
                  _buildPhotoSection(),
                  SizedBox(height: 18),
                  FormBuilderTextField(
                    name: 'firstName',
                    decoration: InputDecoration(
                            labelText: 'First Name',
                      prefixIcon: Icon(Icons.person, color: Color(0xFF8D6748), size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Color(0xFFFFF8E1),
                    ),
                    readOnly: !(widget.isEditMode || widget.isAddMode),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'First name is required';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'lastName',
                    decoration: InputDecoration(
                            labelText: 'Last Name',
                            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF8D6748), size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Color(0xFFFFF8E1),
                    ),
                    readOnly: !(widget.isEditMode || widget.isAddMode),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Last name is required';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'username',
                    decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.account_circle, color: Color(0xFF8D6748), size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Color(0xFFFFF8E1),
                    ),
                    readOnly: !(widget.isEditMode || widget.isAddMode),
                    onChanged: (value) {
                      _usernameDebounceTimer?.cancel();
                      
                      if (value != null && value.trim().isNotEmpty && (widget.isEditMode || widget.isAddMode)) {
                       
                        _usernameDebounceTimer = Timer(Duration(milliseconds: 500), () async {
                          final excludeId = widget.isEditMode && widget.user != null ? widget.user!.id : null;
                          final exists = await _checkUsernameExists(value.trim(), excludeId);
                          if (mounted) {
                            setState(() {
                              if (exists) {
                                usernameError = 'A user with the username "${value.trim()}" already exists.';
                              } else {
                                usernameError = null;
                              }
                            });
                          }
                        });
                      } else {
                        setState(() {
                          usernameError = null;
                        });
                      }
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Username is required';
                      return null;
                    },
                  ),
                  if (usernameError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        usernameError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'email',
                    decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email, color: Color(0xFF8D6748), size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Color(0xFFFFF8E1),
                    ),
                    readOnly: !(widget.isEditMode || widget.isAddMode),
                    onChanged: (value) {
                      _emailDebounceTimer?.cancel();
                      
                      if (value != null && value.trim().isNotEmpty && (widget.isEditMode || widget.isAddMode)) {
                     
                        _emailDebounceTimer = Timer(Duration(milliseconds: 500), () async {
                          final excludeId = widget.isEditMode && widget.user != null ? widget.user!.id : null;
                          final exists = await _checkEmailExists(value.trim(), excludeId);
                          if (mounted) {
                            setState(() {
                              if (exists) {
                                emailError = 'A user with the email "${value.trim()}" already exists.';
                              } else {
                                emailError = null;
                              }
                            });
                          }
                        });
                      } else {
                        setState(() {
                          emailError = null;
                        });
                      }
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Email is required';
                            if (val.length > 100) return 'Email must be at most 100 characters';
                            final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            if (!emailRegex.hasMatch(val)) return 'Enter a valid email address';
                      return null;
                    },
                  ),
                  if (emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        emailError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  if (passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        passwordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  if (confirmPasswordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        confirmPasswordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'phoneNumber',
                    decoration: InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone, color: Color(0xFF8D6748), size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Color(0xFFFFF8E1),
                    ),
                    readOnly: !(widget.isEditMode || widget.isAddMode),
                    onChanged: (value) {
                      if (value == null || value.trim().isEmpty) {
                        if (formKey.currentState != null) {
                          formKey.currentState!.fields['phoneNumber']?.reset();
                          
                          formKey.currentState!.validate();
                        }
                      }
                    },
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
                  SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'age',
                    decoration: InputDecoration(
                      labelText: 'Age',
                      prefixIcon: Icon(Icons.cake, color: Color(0xFF8D6748), size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Color(0xFFFFF8E1),
                    ),
                          readOnly: !(widget.isEditMode || widget.isAddMode),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Age is required';
                            final age = int.tryParse(val);
                            if (age == null) return 'Invalid age';
                            if (age < 13) return 'User must be older than 13';
                            if (age > 120) return 'Invalid age';
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        
                        Divider(height: 20, thickness: 1, color: Color(0xFF8D6748).withOpacity(0.2)),
                        rolesLoading
                          ? Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: CircularProgressIndicator()))
                          : DropdownSearch<Role>.multiSelection(
                              items: allRoles,
                              itemAsString: (role) => role.name,
                              selectedItems: selectedRoles,
                              enabled: widget.isEditMode || widget.isAddMode,
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: 'Roles',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: Icon(Icons.security, color: Color(0xFF8D6748), size: 20),
                                  filled: true,
                                  fillColor: Color(0xFFFFF8E1),
                                ),
                              ),
                              popupProps: PopupPropsMultiSelection.menu(
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    labelText: 'Search role',
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                              ),
                              onChanged: (roles) {
                                setState(() {
                                  selectedRoles = roles;
                                });
                              },
                              validator: (roles) {
                                if ((roles ?? []).isEmpty) return 'At least one role is required';
                                return null;
                              },
                            ),
                        SizedBox(height: 16),
                        if (widget.isAddMode)
                          FormBuilderTextField(
                            name: 'password',
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock, color: Color(0xFF8D6748), size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Color(0xFFFFF8E1),
                            ),
                            obscureText: true,
                            validator: (val) {
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
                        SizedBox(height: 16),
                        if (widget.isEditMode)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CheckboxListTile(
                                title: Text(
                                  'Change Password',
                                  style: TextStyle(
                                    color: Color(0xFF4E342E),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                value: showPasswordFields,
                                onChanged: (value) {
                                  setState(() {
                                    showPasswordFields = value ?? false;
                                    passwordError = null;
                                    confirmPasswordError = null;
                                  });
                                },
                                activeColor: Color(0xFF8D6748),
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                              if (showPasswordFields) ...[
                                SizedBox(height: 16),
                                FormBuilderTextField(
                                  name: 'newPassword',
                                  decoration: InputDecoration(
                                    labelText: 'New Password',
                                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF8D6748), size: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Color(0xFFFFF8E1),
                                  ),
                                  obscureText: true,
                                  onChanged: (value) {
                                    setState(() {
                                      passwordError = null;
                                      confirmPasswordError = null;
                                    });
                                  },
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'New password is required';
                                    }
                                    if (val.length < 8) return 'Password must be at least 8 characters long.';
                                    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$');
                                    if (!regex.hasMatch(val)) {
                                      return 'Password must contain uppercase, lowercase, number, and special character.';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                FormBuilderTextField(
                                  name: 'confirmPassword',
                                  decoration: InputDecoration(
                                    labelText: 'Confirm New Password',
                                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF8D6748), size: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Color(0xFFFFF8E1),
                                  ),
                                  obscureText: true,
                                  onChanged: (value) {
                                    setState(() {
                                      confirmPasswordError = null;
                                    });
                                  },
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please confirm your new password';
                                    }
                                    final newPassword = formKey.currentState?.fields['newPassword']?.value?.toString();
                                    if (val != newPassword) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ],
                          ),
                        SizedBox(height: 16),
                        if (!widget.isEditMode && !widget.isAddMode)
                          FormBuilderTextField(
                            name: 'lastLoginAt',
                            initialValue: widget.user?.lastLoginAt?.toString() ?? '',
                            decoration: InputDecoration(
                              labelText: 'Last Login At',
                              prefixIcon: Icon(Icons.access_time, color: Color(0xFF8D6748), size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Color(0xFFFFF8E1),
                            ),
                            readOnly: true,
                          ),
                        SizedBox(height: 16),
                  DropdownSearch<Country>(
                    items: countries,
                    itemAsString: (c) => c.name,
                    selectedItem: selectedCountry,
                    enabled: widget.isEditMode || widget.isAddMode,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.flag, color: Color(0xFF8D6748), size: 20),
                        filled: true,
                        fillColor: Color(0xFFFFF8E1),
                      ),
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
                    onChanged: (value) {
                      setState(() {
                        selectedCountry = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) return 'Country is required';
                      return null;
                    },
                    ),
                        SizedBox(height: 24),
                  if (widget.isEditMode || widget.isAddMode)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: isSaving ? null : _saveUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8D6748),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
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
                              : Text(widget.isAddMode ? 'Add User' : 'Save Changes'),
                        ),
                        SizedBox(width: 24),
                        OutlinedButton(
                          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF8D6748),
                            side: BorderSide(color: Color(0xFF8D6748)),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                ],
              ),
                  ),
                ),
              ),
                ],
              ),
            ),
          ]),
        ),
        ),
    );
  }
   Future<void> _saveUser() async {
    if (!formKey.currentState!.saveAndValidate()) {
      return;
    }
    setState(() { isSaving = true; usernameError = null; emailError = null; passwordError = null; confirmPasswordError = null; });
    final formData = formKey.currentState!.value;
    final firstName = formData['firstName']?.toString().trim() ?? '';
    final lastName = formData['lastName']?.toString().trim() ?? '';
    final username = formData['username']?.toString().trim() ?? '';
    final email = formData['email']?.toString().trim() ?? '';
    final phoneNumber = formData['phoneNumber']?.toString().trim() ?? '';
    final age = int.tryParse(formData['age']?.toString() ?? '0') ?? 0;
    final roles = selectedRoles;
    final password = formData['password']?.toString();
    final newPassword = formData['newPassword']?.toString();
    final confirmPassword = formData['confirmPassword']?.toString();

  
    try {
      final country = selectedCountry;
      if (country == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a country.')),
        );
        setState(() { isSaving = false; });
        return;
      }
      
      final excludeId = widget.isEditMode && widget.user != null ? widget.user!.id : null;
      
      final usernameExists = await _checkUsernameExists(username, excludeId);
      if (usernameExists) {
        setState(() {
          usernameError = 'A user with the username "$username" already exists.';
          isSaving = false;
        });
        return;
      }
      final emailExists = await _checkEmailExists(email, excludeId);
      if (emailExists) {
        setState(() {
          emailError = 'A user with the email "$email" already exists.';
          isSaving = false;
        });
        return;
      }
      
      // Validate password change if checkbox is checked
      if (widget.isEditMode && showPasswordFields) {
        if (newPassword == null || newPassword.isEmpty) {
          setState(() {
            passwordError = 'New password is required when changing password.';
            isSaving = false;
          });
          return;
        }
        if (confirmPassword == null || confirmPassword.isEmpty) {
          setState(() {
            confirmPasswordError = 'Please confirm your new password.';
            isSaving = false;
          });
          return;
        }
        if (newPassword != confirmPassword) {
          setState(() {
            confirmPasswordError = 'Passwords do not match.';
            isSaving = false;
          });
          return;
        }
        if (newPassword.length < 8) {
          setState(() {
            passwordError = 'Password must be at least 8 characters long.';
            isSaving = false;
          });
          return;
        }
        final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$');
        if (!regex.hasMatch(newPassword)) {
          setState(() {
            passwordError = 'Password must contain uppercase, lowercase, number, and special character.';
            isSaving = false;
          });
          return;
        }
      }
      
      final request = {
        "firstName": firstName,
        "lastName": lastName,
        "username": username,
        "email": email,
        "phoneNumber": phoneNumber.isEmpty ? null : phoneNumber,
        "age": age,
        "countryId": country.id,
        "roleIds": roles.map((r) => r.id).toList(),
        "photoUrl": _existingPhotoUrl,
      };
      
      // Add password to request if changing password
      if (widget.isEditMode && showPasswordFields && newPassword != null && newPassword.isNotEmpty) {
        request['password'] = newPassword;
      }

      if (widget.isAddMode) {
        if (password == null || password.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password is required for new users.')),
          );
          setState(() { isSaving = false; });
          return;
        }
        request['password'] = password;
        final inserted = await userProvider.insert(request);
        if (_selectedImageFile != null && inserted.id != null) {
          try {
            await userProvider.uploadPhoto(inserted.id, _selectedImageFile!);
            final updated = await userProvider.getById(inserted.id);
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
                    Text('Failed to upload user photo: ${e.toString()}'),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text("User added successfully!"),
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
       else if (widget.isEditMode && widget.user != null) {
        await userProvider.update(widget.user!.id, request);
        if (_selectedImageFile != null) {
          try {
            await userProvider.uploadPhoto(widget.user!.id, _selectedImageFile!);
            
            final updated = await userProvider.getById(widget.user!.id);
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
                    Text('Failed to upload user photo: ${e.toString()}'),
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
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text("User updated successfully!"),
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
      Navigator.of(context).pop(true);
    } catch (e) {
      String errorMsg = e.toString();
      
      if (errorMsg.contains('400') || errorMsg.contains('Bad Request')) {
        try {
          final jsonMatch = RegExp(r'\{.*\}').firstMatch(errorMsg);
          if (jsonMatch != null) {
            final jsonStr = jsonMatch.group(0)!;
            final jsonData = jsonDecode(jsonStr);
            if (jsonData is Map<String, dynamic> && jsonData.containsKey('errors')) {
              final errors = jsonData['errors'] as Map<String, dynamic>;
              if (errors.containsKey('userError')) {
                final userErrors = errors['userError'] as List;
                if (userErrors.isNotEmpty) {
                  final specificError = userErrors.first.toString();
                  setState(() {
                    if (specificError.toLowerCase().contains('username')) {
                      usernameError = specificError;
                    } else if (specificError.toLowerCase().contains('email')) {
                      emailError = specificError;
                    } else if (specificError.toLowerCase().contains('password')) {
                      passwordError = specificError;
                    } else {
                      usernameError = specificError;
                    }
                    isSaving = false;
                  });
                  return;
                }
              }
            }
          }
        } catch (parseError) {
        }
      }
      
      if (errorMsg.contains('username or email is already in use')) {
        setState(() {
          usernameError = 'A user with this username already exists.';
          emailError = 'A user with this email already exists.';
          isSaving = false;
        });
        return;
      }
      
      if (errorMsg.contains('already exists')) {
        final existsMatch = RegExp(r'([^"]*already exists[^"]*)').firstMatch(errorMsg);
        if (existsMatch != null && existsMatch.groupCount > 0) {
          final specificMessage = existsMatch.group(1)!.trim();
          setState(() {
            if (specificMessage.toLowerCase().contains('username')) {
              usernameError = specificMessage;
            } else if (specificMessage.toLowerCase().contains('email')) {
              emailError = specificMessage;
            } else {
              usernameError = specificMessage;
            }
            isSaving = false;
          });
          return;
        } else {
          setState(() {
            usernameError = 'A user with this username already exists.';
            emailError = 'A user with this email already exists.';
            isSaving = false;
          });
          return;
        }
      }
      
      if (errorMsg.contains('UserException')) {
        final exceptionMatch = RegExp(r'UserException:\s*(.+)').firstMatch(errorMsg);
        if (exceptionMatch != null && exceptionMatch.groupCount > 0) {
          final specificMessage = exceptionMatch.group(1)!.trim();
          setState(() {
            if (specificMessage.toLowerCase().contains('username')) {
              usernameError = specificMessage;
            } else if (specificMessage.toLowerCase().contains('email')) {
              emailError = specificMessage;
            } else {
              usernameError = specificMessage;
            }
            isSaving = false;
          });
          return;
        } else {
          final altMatch = RegExp(r'UserException\s*:\s*(.+)').firstMatch(errorMsg);
          if (altMatch != null && altMatch.groupCount > 0) {
            final specificMessage = altMatch.group(1)!.trim();
            setState(() {
              if (specificMessage.toLowerCase().contains('username')) {
                usernameError = specificMessage;
              } else if (specificMessage.toLowerCase().contains('email')) {
                emailError = specificMessage;
              } else {
                usernameError = specificMessage;
              }
              isSaving = false;
            });
            return;
          } else {
            setState(() {
              usernameError = 'A user with this username already exists.';
              emailError = 'A user with this email already exists.';
              isSaving = false;
            });
            return;
          }
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Flexible(child: Text(errorMsg)),
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

  Widget _buildPhotoSection() {
    final hasImage = _selectedImageFile != null || (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty);
    String? imageUrl;
    if (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty) {
      if (_existingPhotoUrl!.startsWith('http')) {
        imageUrl = _existingPhotoUrl;
      } else {
        String base = BaseProvider.baseUrl ?? '';
        if (base.endsWith('/api/')) {
          base = base.substring(0, base.length - 5);
        }
        imageUrl = '$base/${_existingPhotoUrl}';
      }
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
          "👤",
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
        final completer = Completer<void>();
        ui.decodeImageFromList(await pickedFile.readAsBytes(), (image) {
          completer.complete();
        });
        await completer.future;
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
}