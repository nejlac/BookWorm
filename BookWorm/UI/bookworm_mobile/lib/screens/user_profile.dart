import 'package:flutter/material.dart';
import '../model/user.dart';
import '../model/country.dart';
import '../model/challenge.dart';
import '../model/user_friend.dart';
import '../providers/country_provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/user_friend_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/base_provider.dart';
import '../providers/user_provider.dart'; 
import '../utils/notification_manager.dart';
import 'my_lists.dart';
import 'challenge_details.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;
  
  const UserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final CountryProvider _countryProvider = CountryProvider();
  final UserFriendProvider _userFriendProvider = UserFriendProvider();
  Country? _userCountry;
  Challenge? _userChallenge;
  bool _isLoadingChallenge = false;
  FriendshipStatus? _friendshipStatus;
  bool _isLoadingFriendship = false;
  bool _isSendingRequest = false;
  int? _currentUserId;
  List<UserFriend>? _sentFriendRequests;
  bool _isLoadingSentRequests = false;

  @override
  void initState() {
    super.initState();
    _loadUserCountry();
    _loadUserChallenge();
    _loadFriendshipStatus();
  }

  Future<void> _loadUserCountry() async {
    try {
      await _countryProvider.fetchCountries();
      final country = _countryProvider.countries.firstWhere(
        (c) => c.id == widget.user.countryId,
        orElse: () => Country(id: 0, name: 'Unknown Country'),
      );
      setState(() {
        _userCountry = country;
      });
    } catch (e) {
      print('Error loading country: $e');
    }
  }

  Future<void> _loadUserChallenge() async {
    setState(() {
      _isLoadingChallenge = true;
    });

    try {
      final challengeProvider = ChallengeProvider();
      final currentYear = DateTime.now().year;
     
      final filter = {
        'username': widget.user.username,
        'year': currentYear,
        'pageSize': 1,
      };

      final result = await challengeProvider.get(filter: filter);
      final challenge = result.items?.isNotEmpty == true ? result.items!.first : null;
      
      setState(() {
        _userChallenge = challenge;
        _isLoadingChallenge = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingChallenge = false;
      });
    }
  }

  Future<void> _loadFriendshipStatus() async {
    final currentUsername = AuthProvider.username;
    if (currentUsername == null) return;
    
    try {
      final userProvider = UserProvider();
      final userResult = await userProvider.get(filter: {'username': currentUsername, 'pageSize': 1});
      final currentUser = userResult.items != null && userResult.items!.isNotEmpty ? userResult.items!.first : null;
      
      if (currentUser == null || currentUser.id == widget.user.id) return;

      setState(() {
        _currentUserId = currentUser.id; 
        _isLoadingFriendship = true;
      });

      final status = await _userFriendProvider.getFriendshipStatus(currentUser.id, widget.user.id);
      
      
      setState(() {
        _friendshipStatus = status;
        _isLoadingFriendship = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFriendship = false;
      });
    }
  }

  Future<void> _loadSentFriendRequests() async {
    final currentUsername = AuthProvider.username;
    if (currentUsername == null) return;
    
    try {
      final userProvider = UserProvider();
      final userResult = await userProvider.get(filter: {'username': currentUsername, 'pageSize': 1});
      final currentUser = userResult.items != null && userResult.items!.isNotEmpty ? userResult.items!.first : null;
      
      if (currentUser == null) return;

      setState(() {
        _isLoadingSentRequests = true;
      });

      final sentRequests = await _userFriendProvider.getSentFriendRequests(currentUser.id);
      setState(() {
        _sentFriendRequests = sentRequests;
        _isLoadingSentRequests = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSentRequests = false;
      });
    }
  }

  Future<void> _sendFriendRequest() async {
    final currentUsername = AuthProvider.username;
    if (currentUsername == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send friend requests')),
      );
      return;
    }

    try {
      final userProvider = UserProvider();
      final userResult = await userProvider.get(filter: {'username': currentUsername, 'pageSize': 1});
      final currentUser = userResult.items != null && userResult.items!.isNotEmpty ? userResult.items!.first : null;
      
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return;
      }

      if (currentUser.id == widget.user.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot send a friend request to yourself')),
        );
        return;
      }
      setState(() {
        _friendshipStatus = FriendshipStatus(
          userId: currentUser.id,
          friendId: widget.user.id,
          status: 0, 
          requestedAt: DateTime.now(),
        );
        _isSendingRequest = false;
      });

      await _userFriendProvider.sendFriendRequest(currentUser.id, widget.user.id);
      await _loadFriendshipStatus(); 
      NotificationManager().refreshNotifications();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to ${widget.user.username}!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      await _loadFriendshipStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending friend request: $e')),
      );
    }
  }

  Future<void> _updateFriendshipStatus(int status) async {
    final currentUsername = AuthProvider.username;
    if (currentUsername == null) return;

    try {
      final userProvider = UserProvider();
      final userResult = await userProvider.get(filter: {'username': currentUsername, 'pageSize': 1});
      final currentUser = userResult.items != null && userResult.items!.isNotEmpty ? userResult.items!.first : null;
      
      if (currentUser == null) return;

      setState(() {
        _friendshipStatus = FriendshipStatus(
          userId: _friendshipStatus?.userId ?? currentUser.id,
          friendId: _friendshipStatus?.friendId ?? widget.user.id,
          status: status,
          requestedAt: _friendshipStatus?.requestedAt ?? DateTime.now(),
        );
        _isSendingRequest = false;
      });

      await _userFriendProvider.updateFriendshipStatus(currentUser.id, widget.user.id, status);
      await _loadFriendshipStatus(); 
      
      NotificationManager().refreshNotifications();
      
      String message = '';
      switch (status) {
        case 1:
          message = 'Friend request accepted!';
          break;
        case 2:
          message = 'Friend request declined.';
          break;
        case 3:
          message = 'User blocked.';
          break;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      await _loadFriendshipStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating friendship status: $e')),
      );
    }
  }

  Future<void> _removeFriend() async {
    final currentUsername = AuthProvider.username;
    if (currentUsername == null) return;

    try {
      final userProvider = UserProvider();
      final userResult = await userProvider.get(filter: {'username': currentUsername, 'pageSize': 1});
      final currentUser = userResult.items != null && userResult.items!.isNotEmpty ? userResult.items!.first : null;
      
      if (currentUser == null) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove Friend'),
          content: Text('Are you sure you want to remove ${widget.user.username} from your friends?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() {
        _friendshipStatus = null; 
        _isSendingRequest = false;
      });

      await _userFriendProvider.removeFriend(currentUser.id, widget.user.id);
      
      await _loadFriendshipStatus(); 
      
      NotificationManager().refreshNotifications();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.user.username} removed from friends.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      await _loadFriendshipStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing friend: $e')),
      );
    }
  }

  Future<void> _cancelFriendRequest() async {
    final currentUsername = AuthProvider.username;
    if (currentUsername == null) return;

    try {
      final userProvider = UserProvider();
      final userResult = await userProvider.get(filter: {'username': currentUsername, 'pageSize': 1});
      final currentUser = userResult.items != null && userResult.items!.isNotEmpty ? userResult.items!.first : null;
      
      if (currentUser == null) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel Friend Request'),
          content: Text('Are you sure you want to cancel the friend request to ${widget.user.username}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel Request'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() {
        _friendshipStatus = null; 
        _isSendingRequest = false;
      });

      await _userFriendProvider.cancelFriendRequest(currentUser.id, widget.user.id);
      await _loadFriendshipStatus(); 
      
      NotificationManager().refreshNotifications();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request to ${widget.user.username} canceled.')),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      await _loadFriendshipStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error canceling friend request: $e')),
      );
    }
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
    final imageUrl = _getUserImageUrl(widget.user);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8D6748)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.user.firstName} ${widget.user.lastName}',
          style: const TextStyle(
            fontFamily: 'Literata',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF5D4037),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            
           
            CircleAvatar(
              radius: 64,
              backgroundColor: const Color(0xFFE0C9A6),
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? const Icon(Icons.person, size: 80, color: Color(0xFF8D6748))
                  : null,
            ),
            
            const SizedBox(height: 24),
            
            Text(
              '${widget.user.firstName} ${widget.user.lastName}',
              style: const TextStyle(
                fontFamily: 'Literata',
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Color(0xFF5D4037),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '@${widget.user.username}',
              style: const TextStyle(
                fontFamily: 'Literata',
                fontSize: 18,
                color: Color(0xFF8D6748),
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildFriendButton(),
            
            const SizedBox(height: 16),
          
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyListsScreen(showAppBar: true, targetUser: widget.user),
                    ),
                  );
                },
                icon: const Icon(Icons.list, color: Color(0xFF5D4037)),
                label: Text(
                  '${widget.user.firstName}\'s lists',
                  style: const TextStyle(
                    color: Color(0xFF5D4037),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF6E3B4),
                  elevation: 0,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
          
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  
                  _buildInfoRow('Age', '${widget.user.age} years old', Icons.cake),
                  const SizedBox(height: 16),
                  _buildInfoRow('Country', _userCountry?.name ?? 'Loading...', Icons.location_on),
                  const SizedBox(height: 16),
                  _buildInfoRow('Member since', _formatDate(widget.user.createdAt), Icons.calendar_today),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
           
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Color(0xFF8D6748), size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Reading Challenge ${DateTime.now().year}',
                        style: const TextStyle(
                          fontFamily: 'Literata',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_isLoadingChallenge)
                    const Center(
                      child: CircularProgressIndicator(color: Color(0xFF8D6748)),
                    )
                  else if (_userChallenge == null)
                  
                    Column(
                      children: [
                        const Icon(
                          Icons.book_outlined,
                          size: 48,
                          color: Color(0xFF8D6748),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No Reading Goal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.user.firstName} hasn\'t set a reading goal for this year.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8D6748),
                          ),
                        ),
                      ],
                    )
                  else
                
                    Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: _userChallenge!.goal > 0 
                                        ? (_userChallenge!.numberOfBooksRead / _userChallenge!.goal).clamp(0.0, 1.0)
                                        : 0.0,
                                    strokeWidth: 8,
                                    backgroundColor: const Color(0xFFE0C9A6),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8D6748)),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${_userChallenge!.numberOfBooksRead}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Color(0xFF5D4037),
                                      ),
                                    ),
                                    Text(
                                      'of ${_userChallenge!.goal}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8D6748),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userChallenge!.isCompleted 
                                        ? 'Challenge Completed! 🎉'
                                        : 'Reading Progress',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: _userChallenge!.isCompleted 
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFF5D4037),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _userChallenge!.isCompleted
                                        ? '${widget.user.firstName} has reached their goal of ${_userChallenge!.goal} books!'
                                        : '${widget.user.firstName} has read ${_userChallenge!.numberOfBooksRead} out of ${_userChallenge!.goal} books this year.',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF8D6748),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Progress: ${((_userChallenge!.numberOfBooksRead / _userChallenge!.goal) * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color(0xFF8D6748),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChallengeDetailsScreen(challenge: _userChallenge!),
                                ),
                              );
                            },
                            icon: const Icon(Icons.visibility, color: Colors.white, size: 16),
                            label: const Text(
                              'See Details',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8D6748),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8D6748), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 14,
                  color: Color(0xFF8D6748),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 16,
                  color: Color(0xFF5D4037),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildFriendButton() {
    final currentUsername = AuthProvider.username;
    if (currentUsername == null || currentUsername == widget.user.username) {
      return const SizedBox.shrink();
    }

    if (_isLoadingFriendship) {
      return const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_friendshipStatus == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: ElevatedButton.icon(
          onPressed: _isSendingRequest ? null : _sendFriendRequest,
          icon: _isSendingRequest 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.person_add, color: Colors.white),
          label: Text(
            _isSendingRequest ? 'Sending...' : 'Send Friend Request',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8D6748),
            elevation: 0,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      );
    }
    switch (_friendshipStatus!.status) {
      case 0:
      
        if (_currentUserId != null && _friendshipStatus!.userId == _currentUserId) {
   
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.schedule, color: Color(0xFF8D6748)),
                    label: const Text(
                      'Request Sent',
                      style: TextStyle(
                        color: Color(0xFF8D6748),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF6E3B4),
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSendingRequest ? null : _cancelFriendRequest,
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF44336),
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSendingRequest ? null : () => _updateFriendshipStatus(1),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'Accept',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSendingRequest ? null : () => _updateFriendshipStatus(2),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text(
                      'Decline',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF44336),
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      case 1: 
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                  label: const Text(
                    'Friends',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F5E8),
                    elevation: 0,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSendingRequest ? null : _removeFriend,
                  icon: const Icon(Icons.person_remove, color: Colors.white),
                  label: const Text(
                    'Remove',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF44336),
                    elevation: 0,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 2: 
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton.icon(
            onPressed: _isSendingRequest ? null : _sendFriendRequest,
            icon: _isSendingRequest 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.person_add, color: Colors.white),
            label: Text(
              _isSendingRequest ? 'Sending...' : 'Send Friend Request',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8D6748),
              elevation: 0,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        );
      case 3: 
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.block, color: Color(0xFF8D6748)),
            label: const Text(
              'User Blocked',
              style: TextStyle(
                color: Color(0xFF8D6748),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF6E3B4),
              elevation: 0,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
} 