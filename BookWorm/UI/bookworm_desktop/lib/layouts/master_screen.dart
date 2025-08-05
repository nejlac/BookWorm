import 'package:bookworm_desktop/screens/author_list.dart';
import 'package:bookworm_desktop/screens/bookReview_list.dart';
import 'package:bookworm_desktop/screens/book_list.dart';
import 'package:bookworm_desktop/screens/country_list.dart';
import 'package:bookworm_desktop/screens/genre_list.dart';
import 'package:bookworm_desktop/screens/reading_challenge_list.dart';
import 'package:bookworm_desktop/screens/statistics.dart';
import 'package:bookworm_desktop/screens/user_list.dart';
import 'package:flutter/material.dart';
import 'package:bookworm_desktop/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../main.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key, required this.child, required this.title, this.selectedIndex = 0});
  final Widget child;
  final String title;
  final int selectedIndex;
 @override
  State<MasterScreen> createState() => _MasterScreenState();
}
class _MasterScreenState extends State<MasterScreen> {
  late int _selectedIndex;
  late Widget _currentChild;
  late String _currentTitle;
  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.menu_book_rounded, label: 'Books', screen: BookList()),
    _NavItem(icon: Icons.people_alt_rounded, label: 'Users', screen: UserList()),
    _NavItem(icon: Icons.people_alt_rounded, label: 'Authors', screen: AuthorList()),
    _NavItem(icon: Icons.category, label: 'Genres', screen: GenreList()),
    _NavItem(icon: Icons.flag, label: 'Countries', screen: CountryList()),
    _NavItem(icon: Icons.reviews, label: 'Reviews', screen: BookReviewList()),
    _NavItem(icon: Icons.my_library_books_outlined, label: 'Challenges', screen: ReadingChallengeList()),
    _NavItem(icon: Icons.auto_graph, label: 'Statistics', screen: StatisticsScreen()),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _currentChild = widget.child;
    _currentTitle = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatisticsProvider(),
      child: Scaffold(
        body: Row(
          children: [
            Container(
              width: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEFEBE9), Color(0xFFD7CCC8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.08),
                    blurRadius: 12,
                    offset: Offset(2, 0),
                  ),
                ],
                border: const Border(
                  right: BorderSide(
                    color: Color(0xFFBCAAA4),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.06),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(0xFF8D6748),
                          child: Text(
                            (AuthProvider.username?.isNotEmpty ?? false)
                                ? AuthProvider.username![0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AuthProvider.username ?? 'Guest',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Literata',
                                  fontSize: 16,
                                  color: Color(0xFF5D4037),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Welcome!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8D6748),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                 
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'BookWorm',
                        style: TextStyle(
                          fontFamily: 'Literata',
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Color(0xFF5D4037),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _navItems.length,
                      itemBuilder: (context, index) {
                        final navItem = _navItems[index];
                        return _buildNavTile(
                          icon: navItem.icon,
                          label: navItem.label,
                          selected: _selectedIndex == index,
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                              if (navItem.screen != null) {
                                _currentChild = navItem.screen!;
                                _currentTitle = navItem.label;
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          AuthProvider.logout();
                          clearLoginFields();
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          }
                        },
                        icon: const Icon(Icons.logout, color: Color(0xFF8D6748)),
                        label: const Text('Logout', style: TextStyle(color: Color(0xFF8D6748), fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color(0xFF8D6748), width: 1.2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _currentChild),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile({required IconData icon, required String label, required VoidCallback onTap, bool selected = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: selected ? Color(0xFF8D6748).withOpacity(0.13) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Color(0xFF8D6748).withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
      child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading: Icon(icon, color: selected ? Color(0xFF8D6748) : Color(0xFF5D4037), size: 26),
        title: Text(
          label,
              style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Literata',
                fontSize: 17,
                color: selected ? Color(0xFF8D6748) : Color(0xFF5D4037),
              ),
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget? screen;
  _NavItem({required this.icon, required this.label, this.screen});
}