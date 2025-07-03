import 'package:bookworm_desktop/screens/book_list.dart';
import 'package:flutter/material.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key, required this.child, required this.title});
  final Widget child;
  final String title;
 @override
  State<MasterScreen> createState() => _MasterScreenState();
}
class _MasterScreenState extends State<MasterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: Theme.of(context).drawerTheme.backgroundColor ?? Colors.grey[200],
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
                const SizedBox(height: 32),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'BookWorm',
                      style: TextStyle(
                        fontFamily: 'Literata',
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Color(0xFF5D4037),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView(
                    children: [
                      _buildNavTile(
                        icon: Icons.menu_book_rounded,
                        label: 'Books',
                        onTap: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BookList()));
                        },
                      ),
                      _buildNavTile(icon: Icons.people_alt_rounded, label: 'Users', onTap: () {}),
                      _buildNavTile(icon: Icons.people_alt_rounded, label: 'Authors', onTap: () {}),
                      _buildNavTile(icon: Icons.reviews, label: 'Reviews', onTap: () {}),
                      _buildNavTile(icon: Icons.my_library_books_outlined, label: 'Challanges', onTap: () {}),
                      _buildNavTile(icon: Icons.auto_graph, label: 'Statistics', onTap: () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildNavTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        leading: Icon(icon, color: const Color(0xFF5D4037)), // darker brown
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Literata',
            fontSize: 18,
            color: Color(0xFF5D4037), // darker brown
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}