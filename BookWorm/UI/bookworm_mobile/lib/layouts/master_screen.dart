import 'package:bookworm_mobile/main.dart';
import 'package:bookworm_mobile/screens/homepage.dart';
import 'package:bookworm_mobile/screens/profile.dart';
import 'package:bookworm_mobile/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:bookworm_mobile/providers/auth_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:bookworm_mobile/screens/change_password.dart';
import 'package:bookworm_mobile/screens/add_book.dart';

class MasterScreen extends StatefulWidget {
  final int initialIndex;
  const MasterScreen({super.key, this.initialIndex = 0});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  late int _selectedIndex;
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }
  final GlobalKey _profileSettingsKey = GlobalKey();
  final GlobalKey _searchScreenKey = GlobalKey();

  static final List<Widget> _pages = <Widget>[
    HomePage(),
    SearchScreen(key: GlobalKey()),
    Center(child: Text('Lists', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
    ProfileScreen(),
  ];

  static const List<String> _titles = [
    'Home',
    'Search',
    'Lists',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _refreshSearchScreen() {
    setState(() {
      // Recreate the SearchScreen to force a refresh
      _pages[1] = SearchScreen(key: GlobalKey());
    });
  }

  void _showProfileMenu(BuildContext context) async {
    final RenderBox button = _profileSettingsKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);
    final result = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + button.size.height,
        position.dx + button.size.width,
        position.dy,
      ),
      color: const Color(0xFFFFF8E1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        PopupMenuItem(
          value: 'change_password',
          child: Row(
            children: const [
              Icon(Icons.lock, color: Color(0xFF8D6748)),
              SizedBox(width: 10),
              Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8D6748))),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout, color: Color(0xFF8D6748)),
              SizedBox(width: 10),
              Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8D6748))),
            ],
          ),
        ),
      ],
    );
    if (result == 'logout') {
      AuthProvider.logout();
      LoginPage.clearFields(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Color(0xFF8D6748)),
              SizedBox(width: 12),
              Text('Logged out successfully!', style: TextStyle(fontFamily: 'Literata', color: Color(0xFF8D6748), fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: const Color(0xFFFFF8E1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (result == 'change_password') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 32,
              width: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Text(
              _titles[_selectedIndex],
              style: const TextStyle(
                fontFamily: 'Literata',
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF5D4037),
              ),
            ),
          ],
        ),
        actions: [
          if (_selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF8D6748), size: 28),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddBookScreen()),
                );
                if (result == true) {
                  // Refresh the search page if a book was added
                  _refreshSearchScreen();
                }
              },
            )
          else if (_selectedIndex == 3)
            IconButton(
              key: _profileSettingsKey,
              icon: const Icon(Icons.settings, color: Color(0xFF8D6748), size: 28),
              onPressed: () => _showProfileMenu(context),
            )
          else
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF8D6748), size: 28),
              onPressed: () {},
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 240, 228, 187),
        selectedItemColor: const Color(0xFF8D6748),
        unselectedItemColor: const Color(0xFF5D4037),
        selectedLabelStyle: const TextStyle(fontFamily: 'Literata', fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Literata'),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFFFAF4),
    );
  }
}