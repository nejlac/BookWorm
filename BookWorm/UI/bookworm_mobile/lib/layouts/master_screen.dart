import 'package:bookworm_mobile/main.dart';
import 'package:bookworm_mobile/screens/homepage.dart';
import 'package:bookworm_mobile/screens/profile.dart';
import 'package:bookworm_mobile/screens/search.dart';
import 'package:bookworm_mobile/screens/my_lists.dart';
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
  final GlobalKey _myListsScreenKey = GlobalKey();

  List<Widget> _pages = <Widget>[
    HomePage(),
    SearchScreen(key: GlobalKey()),
    MyListsScreen(key: GlobalKey()),
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

  void _refreshListsScreen() {
    setState(() {
      // Recreate the MyListsScreen to force a refresh
      _pages[2] = MyListsScreen(key: GlobalKey());
    });
  }



  void _showProfileMenu(BuildContext context) async {
    // Get the position of the settings button
    final RenderBox? button = _profileSettingsKey.currentContext?.findRenderObject() as RenderBox?;
    RelativeRect position;
    
    if (button != null) {
      // If we have a key (profile tab), use the button position
      final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
      final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
      position = RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + button.size.height,
        buttonPosition.dx + button.size.width,
        buttonPosition.dy,
      );
    } else {
      // For other tabs, position the menu in the top-right corner
      position = RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 200, // 200px from right edge
        80, // 80px from top
        20, // 20px from right edge
        0,
      );
    }
    
    final result = await showMenu(
      context: context,
      position: position,
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
          // Removed plus button for Lists tab since MyListsScreen has its own floating action button
          else if (_selectedIndex == 0 || _selectedIndex == 2 || _selectedIndex == 3)
            IconButton(
              key: _selectedIndex == 3 ? _profileSettingsKey : null,
              icon: const Icon(Icons.settings, color: Color(0xFF8D6748), size: 28),
              onPressed: () => _showProfileMenu(context),
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