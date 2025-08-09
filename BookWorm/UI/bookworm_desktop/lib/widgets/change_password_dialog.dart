import 'package:flutter/material.dart';
import 'package:bookworm_desktop/providers/auth_provider.dart';
import 'package:bookworm_desktop/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:bookworm_desktop/main.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({Key? key}) : super(key: key);

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isSaving = false;
  String? errorMsg;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { isSaving = true; errorMsg = null; });
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final username = AuthProvider.username;
      if (username == null) throw Exception('No user logged in');
      final result = await userProvider.get(filter: {'username': username, 'pageSize': 1});
      final user = result.items != null && result.items!.isNotEmpty ? result.items!.first : null;
      if (user == null) throw Exception('User not found');
      if (currentPasswordController.text.trim() != (AuthProvider.password ?? '')) {
        setState(() {
          errorMsg = 'Current password is incorrect.';
          isSaving = false;
        });
        return;
      }
      final request = {
        'firstName': user.firstName,
        'lastName': user.lastName,
        'username': user.username,
        'email': user.email,
        'phoneNumber': user.phoneNumber.isEmpty ? null : user.phoneNumber,
        'age': user.age,
        'countryId': user.countryId,
        'photoUrl': user.photoUrl,
        'roleIds': user.roles.isNotEmpty ? user.roles.map((r) => r.id).toList() : [2],
        'password': newPasswordController.text.trim(),
      };
      await userProvider.update(user.id, request);
      if (mounted) {
                 showDialog(
           context: context,
           barrierDismissible: false,
           builder: (context) => Dialog(
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
             backgroundColor: const Color(0xFFFFF8E1),
             child: Container(
               width: 300,
               padding: const EdgeInsets.all(20.0),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Icon(Icons.lock_open, color: Color(0xFF8D6748), size: 40),
                   const SizedBox(height: 12),
                   const Text(
                     'Password changed!',
                     style: TextStyle(
                       fontFamily: 'Literata',
                       fontWeight: FontWeight.bold,
                       fontSize: 18,
                       color: Color(0xFF8D6748),
                     ),
                   ),
                   const SizedBox(height: 8),
                   const Text(
                     'Your password has been updated.\nYou will be redirected to login.',
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       fontFamily: 'Literata',
                       fontSize: 14,
                       color: Color(0xFF5D4037),
                     ),
                   ),
                   const SizedBox(height: 16),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFF8D6748),
                         foregroundColor: Colors.white,
                         elevation: 0,
                         padding: const EdgeInsets.symmetric(vertical: 10),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                       ),
                       onPressed: () {
                         AuthProvider.clearAuth();
                         LoginPage.clearFields(context);
                         Navigator.pushReplacement(
                           context,
                           MaterialPageRoute(builder: (context) => LoginPage()),
                         );
                       },
                       child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
      setState(() { isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(28.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock, color: Color(0xFF8D6748), size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Change Password',
                    style: TextStyle(
                      fontFamily: 'Literata',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    errorMsg!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF8D6748)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xFFFFF8E1),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Current password is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF8D6748)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xFFFFF8E1),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'New password is required';
                  if (val.length < 8) return 'Password must be at least 8 characters long.';
                  final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}');
                  if (!regex.hasMatch(val)) {
                    return 'Password must contain uppercase, lowercase, number, and special character.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF8D6748)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xFFFFF8E1),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please confirm your new password';
                  if (val != newPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF8D6748),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8D6748),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Change Password',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
