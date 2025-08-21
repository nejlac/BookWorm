import 'package:bookworm_mobile/main.dart';
import 'package:bookworm_mobile/screens/homepage.dart';
import 'package:bookworm_mobile/screens/profile.dart';
import 'package:bookworm_mobile/screens/search.dart';
import 'package:bookworm_mobile/screens/my_lists.dart';
import 'package:flutter/material.dart';
import 'package:bookworm_mobile/providers/auth_provider.dart';
import 'package:bookworm_mobile/providers/user_friend_provider.dart';
import 'package:bookworm_mobile/providers/user_provider.dart';
import 'package:bookworm_mobile/model/user_friend.dart';
import 'package:bookworm_mobile/screens/change_password.dart';
import 'package:bookworm_mobile/screens/add_book.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:bookworm_mobile/utils/notification_manager.dart';
import 'package:bookworm_mobile/screens/book_clubs.dart';


class MasterScreen extends StatefulWidget {
  final int initialIndex;
  const MasterScreen({super.key, this.initialIndex = 0});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> with WidgetsBindingObserver {
  late int _selectedIndex;
  List<UserFriend>? _pendingFriendRequests;
  bool _isLoadingNotifications = false;
  int? _currentUserId;
  
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadCurrentUserAndNotifications();
    WidgetsBinding.instance.addObserver(this);
    
    NotificationManager().setRefreshCallback(() {
      _loadPendingFriendRequests();
    });
    
    _pages = <Widget>[
      HomePage(key: _homePageKey),
      SearchScreen(key: GlobalKey()),
      BookClubsScreen(currentUserId: _currentUserId ?? 0),
      MyListsScreen(key: _listsPageKey),
      ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadPendingFriendRequests();
    }
  }
  final GlobalKey _profileSettingsKey = GlobalKey();
  final GlobalKey _homePageKey = GlobalKey();
  final GlobalKey _listsPageKey = GlobalKey();
  

  List<Widget> _pages = <Widget>[
    HomePage(),
    SearchScreen(key: GlobalKey()),
    BookClubsScreen(currentUserId: 0),
    MyListsScreen(key: GlobalKey()),
    ProfileScreen(),
  ];

  static const List<String> _titles = [
    'Home',
    'Search',
    'Book Clubs',
    'Lists',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
   
    if (index == 0) {
      final homePageState = _homePageKey.currentState as dynamic;
      homePageState?.refreshFriendshipStatuses();
    } else if (index == 2) {
      final listsPageState = _listsPageKey.currentState as dynamic;
      listsPageState?.refreshReadingLists();
    }
  }

  void _refreshSearchScreen() {
    setState(() {
      _pages[1] = SearchScreen(key: GlobalKey());
    });
  }

 

  Future<void> _loadCurrentUserAndNotifications() async {
    final username = AuthProvider.username;
    if (username == null) return;

    try {
      final userProvider = UserProvider();
      final userResult = await userProvider.get(filter: {'username': username, 'pageSize': 1});
      final currentUser = userResult.items != null && userResult.items!.isNotEmpty ? userResult.items!.first : null;
      
      if (currentUser != null) {
        setState(() {
          _currentUserId = currentUser.id;
        });
        await _loadPendingFriendRequests();
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _loadPendingFriendRequests() async {
    if (_currentUserId == null) return;

    setState(() {
      _isLoadingNotifications = true;
    });

    try {
      final userFriendProvider = UserFriendProvider();
      final pendingRequests = await userFriendProvider.getPendingFriendRequests(_currentUserId!);
      
      setState(() {
        _pendingFriendRequests = pendingRequests;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      
      setState(() {
        _isLoadingNotifications = false;
      });
    }
  }

  void _showFriendRequestsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Friend Requests',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF8D6748)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingNotifications)
                    const Center(child: CircularProgressIndicator())
                  else if (_pendingFriendRequests == null || _pendingFriendRequests!.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No pending friend requests.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8D6748),
                        ),
                      ),
                    )
                  else
                    Container(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _pendingFriendRequests!.length,
                        itemBuilder: (context, index) {
                          final request = _pendingFriendRequests![index];
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: InkWell(
                              onTap: () async {
                              
                                try {
                                 
                                  final userProvider = UserProvider();
                                  final userResult = await userProvider.getById(request.userId);
                               
                                  if (userResult != null) {
                                  
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  } else {
                                  
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('User not found')),
                                    );
                                  }
                                } catch (e) {
                                
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error loading user profile: $e')),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundImage: _getUserImageUrl(request.userPhotoUrl) != null 
                                      ? NetworkImage(_getUserImageUrl(request.userPhotoUrl)!) 
                                      : null,
                                  child: _getUserImageUrl(request.userPhotoUrl) == null 
                                      ? const Icon(Icons.person, color: Color(0xFF8D6748))
                                      : null,
                                ),
                                title: Text(
                                  request.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5D4037),
                                  ),
                                ),
                                subtitle: Text(
                                  'Wants to be your friend',
                                  style: const TextStyle(
                                    color: Color(0xFF8D6748),
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        await _handleFriendRequest(request, 1); 
                                        setDialogState(() {});
                                      },
                                      icon: const Icon(Icons.check, color: Color(0xFF4CAF50)),
                                      tooltip: 'Accept',
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await _handleFriendRequest(request, 2); 
                                        setDialogState(() {});
                                      },
                                      icon: const Icon(Icons.close, color: Color(0xFFF44336)),
                                      tooltip: 'Decline',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleFriendRequest(UserFriend request, int status) async {
    try {
      setState(() {
        _isLoadingNotifications = true;
      });

      final userFriendProvider = UserFriendProvider();
      await userFriendProvider.updateFriendshipStatus(_currentUserId!, request.userId, status);
      
      await _loadPendingFriendRequests();
      
      NotificationManager().refreshNotifications();
      
      final homePageState = _homePageKey.currentState as dynamic;
      homePageState?.refreshFriendRecommendations();
      
      String message = status == 1 ? 'Friend request accepted!' : 'Friend request declined.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      await _loadPendingFriendRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error handling friend request: $e')),
      );
    }
  }

  String? _getUserImageUrl(String photoUrl) {
    if (photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http')) {
      return photoUrl;
    } else {
      String base = BaseProvider.baseUrl ?? '';
      if (base.endsWith('/api/')) {
        base = base.substring(0, base.length - 5);
      }
      return '$base/$photoUrl';
    }
  }



  Future<void> refreshNotifications() async {
    await _loadPendingFriendRequests();
  }

  void _showProfileMenu(BuildContext context) async {
    final RenderBox? button = _profileSettingsKey.currentContext?.findRenderObject() as RenderBox?;
    RelativeRect position;
    
    if (button != null) {
      final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
      final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
      position = RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + button.size.height,
        buttonPosition.dx + button.size.width,
        buttonPosition.dy,
      );
    } else {
      position = RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 200, 
        80, 
        20, 
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
                  _refreshSearchScreen();
                }
              },
            )
          else if (_selectedIndex == 0 || _selectedIndex == 2 || _selectedIndex == 3 || _selectedIndex == 4) ...[
            if (_selectedIndex != 4) ...[
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Color(0xFF8D6748), size: 28),
                    onPressed: () => _showFriendRequestsDialog(),
                  ),
                  if (_pendingFriendRequests != null && _pendingFriendRequests!.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF44336),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${_pendingFriendRequests!.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
            IconButton(
              key: _selectedIndex == 3 || _selectedIndex == 4 ? _profileSettingsKey : null,
              icon: const Icon(Icons.settings, color: Color(0xFF8D6748), size: 28),
              onPressed: () => _showProfileMenu(context),
            ),
          ],
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
            icon: Icon(Icons.groups),
            label: 'Book Clubs',
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