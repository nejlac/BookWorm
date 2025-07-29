import 'package:bookworm_mobile/screens/edit_profile.dart';
import 'package:bookworm_mobile/screens/my_lists.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/base_provider.dart';
import '../model/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final username = AuthProvider.username;
    if (username == null) return;
    final result = await userProvider.get(filter: {'username': username, 'pageSize': 1});
    setState(() {
      user = result.items != null && result.items!.isNotEmpty ? result.items!.first : null;
      isLoading = false;
    });
  }

  String? _getUserImageUrl(User user) {
    final hasImage = user.photoUrl != null && user.photoUrl!.isNotEmpty;
    if (!hasImage) return null;
    if (user.photoUrl!.startsWith('http')) {
      return user.photoUrl!;
    } else {
      String base = BaseProvider.baseUrl ?? '';
      if (base.endsWith('/api/')) {
        base = base.substring(0, base.length - 5);
      }
      return '$base/${user.photoUrl}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (user == null) {
      return const Center(child: Text('User not found'));
    }
    final imageUrl = _getUserImageUrl(user!);
    return Container(
      color: const Color(0xFFFFFAF4),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 36),
            
            CircleAvatar(
              radius: 64,
              backgroundColor: const Color(0xFFE0C9A6),
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? const Icon(Icons.person, size: 80, color: Color(0xFF8D6748))
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              '${user!.firstName} ${user!.lastName}',
              style: const TextStyle(
                fontFamily: 'Literata',
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '@${user!.username}',
              style: const TextStyle(
                fontFamily: 'Literata',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyListsScreen(showAppBar: true, targetUser: user),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list, color: Color(0xFF5D4037)),
                    label: const Text('My lists', style: TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.bold, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF6E3B4),
                      elevation: 0,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfileScreen()),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Color(0xFF5D4037)),
                    label: const Text('Edit Profile', style: TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.bold, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF6E3B4),
                      elevation: 0,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            // Reading goal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                children: [
                  
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          value: 0.93, // Example: 93%
                          strokeWidth: 7,
                          backgroundColor: const Color(0xFFF6E3B4),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
                        ),
                      ),
                      const Text('93%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFB87333))),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Reading goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF5D4037))),
                        SizedBox(height: 4),
                        Text('You have read 28 out of 30 books this year.\nKeep up until you reach your goal!', style: TextStyle(fontSize: 13, color: Color(0xFF8D6748))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D6748),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('See more', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
