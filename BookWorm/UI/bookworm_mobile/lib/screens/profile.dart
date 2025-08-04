import 'package:bookworm_mobile/screens/edit_profile.dart';
import 'package:bookworm_mobile/screens/my_lists.dart';
import 'package:bookworm_mobile/screens/challenge_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/base_provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/user_statistics_provider.dart';
import '../providers/user_friend_provider.dart';
import '../model/user.dart';
import '../model/challenge.dart';
import '../model/user_statistics.dart';
import '../model/user_friend.dart';
import '../widgets/genre_pie_chart.dart';
import '../utils/genre_colors.dart';
import '../screens/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  Challenge? currentChallenge;
  bool isLoading = true;
  bool isLoadingChallenge = false;
  bool isLoadingStatistics = false;
  List<UserGenreStatistic>? userGenres;
  UserRatingStatistics? userRatingStats;
  List<UserFriend>? userFriends;
  bool isLoadingFriends = false;

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
    
    if (user != null) {
      _loadCurrentChallenge();
      _loadUserStatistics();
      _loadUserFriends();
    }
  }

  Future<void> _loadCurrentChallenge() async {
    if (user == null) return;
    
    setState(() {
      isLoadingChallenge = true;
    });

    try {
      final challengeProvider = ChallengeProvider();
      final currentYear = DateTime.now().year;
      final challenge = await challengeProvider.getUserChallenge(user!.id, currentYear);
      
      setState(() {
        currentChallenge = challenge;
        isLoadingChallenge = false;
      });
    } catch (e) {
      setState(() {
        isLoadingChallenge = false;
      });
    }
  }

  Future<void> _loadUserStatistics() async {
    if (user == null) return;
    
    setState(() {
      isLoadingStatistics = true;
    });

    try {
      final statisticsProvider = UserStatisticsProvider();
      final currentYear = DateTime.now().year;
      
      final results = await Future.wait([
        statisticsProvider.getUserMostReadGenres(user!.id, year: currentYear),
        statisticsProvider.getUserRatingStatistics(user!.id, year: currentYear),
      ]);
      
      setState(() {
        userGenres = results[0] as List<UserGenreStatistic>;
        userRatingStats = results[1] as UserRatingStatistics;
        isLoadingStatistics = false;
      });
    } catch (e) {
      setState(() {
        isLoadingStatistics = false;
      });
    }
  }

  Future<void> _loadUserFriends() async {
    if (user == null) return;
    
    setState(() {
      isLoadingFriends = true;
    });

    try {
      final userFriendProvider = UserFriendProvider();
      final friends = await userFriendProvider.getUserFriends(user!.id);
      
      setState(() {
        userFriends = friends;
        isLoadingFriends = false;
      });
    } catch (e) {
      setState(() {
        isLoadingFriends = false;
      });
    }
  }

  void _showFriendsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
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
                    'My Friends',
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
              if (isLoadingFriends)
                const Center(child: CircularProgressIndicator())
              else if (userFriends == null || userFriends!.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No friends yet.\nStart adding friends to see them here!',
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
                    itemCount: userFriends!.length,
                    itemBuilder: (context, index) {
                      final friend = userFriends![index];
                      final friendName = friend.userId == user!.id 
                          ? friend.friendName 
                          : friend.userName;
                      final friendPhotoUrl = friend.userId == user!.id 
                          ? friend.friendPhotoUrl 
                          : friend.userPhotoUrl;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          onTap: () async {
                            final targetUserId = friend.userId == user!.id 
                                ? friend.friendId 
                                : friend.userId;
                          
                            
                            try {
                              final userProvider = UserProvider();
                              final userResult = await userProvider.getById(targetUserId);
                            
                              
                              if (userResult != null) {
                               
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfileScreen(user: userResult),
                                  ),
                                );
                              
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
                              backgroundImage: _getUserImageUrl(friendPhotoUrl) != null 
                                  ? NetworkImage(_getUserImageUrl(friendPhotoUrl)!) 
                                  : null,
                              child: _getUserImageUrl(friendPhotoUrl) == null 
                                  ? const Icon(Icons.person, color: Color(0xFF8D6748))
                                  : null,
                            ),
                            title: Text(
                              friendName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D4037),
                              ),
                            ),
                            subtitle: Text(
                              'Friends since ${_formatDate(friend.requestedAt)}',
                              style: const TextStyle(
                                color: Color(0xFF8D6748),
                                fontSize: 12,
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () async {
                                await _removeFriend(friend);
                                setDialogState(() {});
                              },
                              icon: const Icon(Icons.person_remove, color: Color(0xFFF44336)),
                              tooltip: 'Remove friend',
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
      ),
    ));
  }

  Future<void> _removeFriend(UserFriend friendship) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Are you sure you want to remove this friend?'),
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

    try {
      final userFriendProvider = UserFriendProvider();
      final friendId = friendship.userId == user!.id 
          ? friendship.friendId 
          : friendship.userId;
      
      await userFriendProvider.removeFriend(user!.id, friendId);
      await _loadUserFriends(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing friend: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  Future<void> _createNewChallenge() async {
    if (user == null) return;

    final goalController = TextEditingController();
    final currentYear = DateTime.now().year;
    
    final result = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        builder: (context, value, child) => Transform.scale(
          scale: value,
          child: AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: const Color(0xFFFFF8E1),
            title: Text(
              'Join Reading Challenge $currentYear',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF5D4037),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    builder: (context, textValue, child) => Opacity(
                      opacity: textValue,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - textValue)),
                        child: Text(
                          'Set your reading goal for $currentYear:',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8D6748),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    builder: (context, fieldValue, child) => Transform.scale(
                      scale: fieldValue,
                      child: TextField(
                        controller: goalController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Number of books',
                          hintText: 'e.g., 30',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF8D6748), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.book, color: Color(0xFF8D6748)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutBack,
                builder: (context, buttonValue, child) => Transform.scale(
                  scale: buttonValue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Color(0xFF8D6748)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final goal = int.tryParse(goalController.text);
                          final currentYear = DateTime.now().year;
                        
                          if (goal == null || goal < 1 || goal > 1000) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Goal must be between 1 and 1000'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          
                          if (currentYear < 2000 || currentYear > DateTime.now().year + 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Year must be between 2000 and ${DateTime.now().year + 1}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        
                          Navigator.pop(context, goal);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D6748),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Join Challenge',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      try {
        setState(() {
          isLoadingChallenge = true;
        });

        final challengeProvider = ChallengeProvider();
        final newChallenge = await challengeProvider.createChallenge(user!.id, result, currentYear);
        
        setState(() {
          currentChallenge = newChallenge;
          isLoadingChallenge = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully joined the $currentYear reading challenge!')),
        );
      } catch (e) {
        setState(() {
          isLoadingChallenge = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating challenge: $e')),
        );
      }
    }
  }

  Future<void> _editChallenge(Challenge challenge) async {
    if (user == null) return;

    final goalController = TextEditingController(text: challenge.goal.toString());
    final currentYear = DateTime.now().year;
    
    final result = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        builder: (context, value, child) => Transform.scale(
          scale: value,
          child: AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: const Color(0xFFFFF8E1),
            title: Text(
              'Edit Reading Challenge $currentYear',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF5D4037),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    builder: (context, textValue, child) => Opacity(
                      opacity: textValue,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - textValue)),
                        child: Text(
                          'Update your reading goal for $currentYear:',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8D6748),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    builder: (context, fieldValue, child) => Transform.scale(
                      scale: fieldValue,
                      child: TextField(
                        controller: goalController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Number of books',
                          hintText: 'e.g., 30',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF8D6748), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.book, color: Color(0xFF8D6748)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutBack,
                builder: (context, buttonValue, child) => Transform.scale(
                  scale: buttonValue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Color(0xFF8D6748)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final goal = int.tryParse(goalController.text);
                          
                          if (goal == null || goal < 1 || goal > 1000) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Goal must be between 1 and 1000'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          Navigator.pop(context, goal);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D6748),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Update Goal',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      try {
        setState(() {
          isLoadingChallenge = true;
        });

        final challengeProvider = ChallengeProvider();
        final updatedChallenge = await challengeProvider.updateChallenge(
          challenge.id,
          result,
          currentYear,
        );
        
        setState(() {
          currentChallenge = updatedChallenge;
          isLoadingChallenge = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully updated your reading goal to $result books!')),
        );
      } catch (e) {
        setState(() {
          isLoadingChallenge = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating challenge: $e')),
        );
      }
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
    final imageUrl = _getUserImageUrl(user!.photoUrl ?? '');
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
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showFriendsDialog();
                    },
                    icon: const Icon(Icons.people, color: Color(0xFF5D4037)),
                    label: Text(
                      'My Friends (${userFriends?.length ?? 0})', 
                      style: const TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.bold, fontSize: 18)
                    ),
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
       
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
               
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) => Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8D6748), Color(0xFF5D4037)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8D6748).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.emoji_events,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Reading Challenge ${DateTime.now().year}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  if (isLoadingChallenge)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: Color(0xFF8D6748)),
                          ),
                        ),
                      ),
                    )
                  else if (currentChallenge == null)
                
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) => Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFF8E1), Color(0xFFF6E3B4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE0C9A6), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8D6748).withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8D6748).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.add_circle_outline,
                                  size: 48,
                                  color: Color(0xFF8D6748),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Active Challenge',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Join the reading challenge and set your goal for this year!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8D6748),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.elasticOut,
                                builder: (context, buttonValue, child) => Transform.scale(
                                  scale: buttonValue,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF8D6748), Color(0xFF5D4037)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF8D6748).withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: _createNewChallenge,
                                      icon: const Icon(Icons.emoji_events, color: Colors.white),
                                      label: const Text(
                                        'Join Challenge',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                 
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) => Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFF8E1), Color(0xFFF6E3B4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE0C9A6), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8D6748).withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFE0C9A6), Color(0xFFD4C4A8)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF8D6748).withOpacity(0.2),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: TweenAnimationBuilder<double>(
                                          tween: Tween(begin: 0.0, end: currentChallenge!.goal > 0 
                                              ? (currentChallenge!.numberOfBooksRead / currentChallenge!.goal).clamp(0.0, 1.0)
                                              : 0.0),
                                          duration: const Duration(milliseconds: 1500),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, progressValue, child) => CircularProgressIndicator(
                                            value: progressValue,
                                            strokeWidth: 10,
                                            backgroundColor: const Color(0xFFE0C9A6),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              currentChallenge!.isCompleted 
                                                  ? const Color(0xFF4CAF50)
                                                  : const Color(0xFF8D6748),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          TweenAnimationBuilder<int>(
                                            tween: IntTween(begin: 0, end: currentChallenge!.numberOfBooksRead),
                                            duration: const Duration(milliseconds: 1000),
                                            curve: Curves.easeOutCubic,
                                            builder: (context, value, child) => Text(
                                              '$value',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                                color: Color(0xFF5D4037),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'of ${currentChallenge!.goal}',
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
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: currentChallenge!.isCompleted 
                                                ? const Color(0xFF4CAF50).withOpacity(0.2)
                                                : const Color(0xFF8D6748).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Text(
                                            currentChallenge!.isCompleted 
                                                ? '🎉 Challenge Completed!'
                                                : '📚 Reading Progress',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: currentChallenge!.isCompleted 
                                                  ? const Color(0xFF4CAF50)
                                                  : const Color(0xFF5D4037),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          currentChallenge!.isCompleted
                                              ? 'Congratulations! You\'ve reached your goal of ${currentChallenge!.goal} books.'
                                              : 'You have read ${currentChallenge!.numberOfBooksRead} out of ${currentChallenge!.goal} books this year.\nKeep going until you reach your goal!',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF8D6748),
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8D6748).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'Progress: ${((currentChallenge!.numberOfBooksRead / currentChallenge!.goal) * 100).toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Color(0xFF8D6748),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                        
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 1200),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) => Transform.scale(
                                      scale: value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF5D4037), Color(0xFF8D6748)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF5D4037).withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () => _editChallenge(currentChallenge!),
                                          icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                                          label: const Text(
                                            'Edit Goal',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 1400),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) => Transform.scale(
                                      scale: value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF8D6748), Color(0xFF5D4037)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF8D6748).withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChallengeDetailsScreen(challenge: currentChallenge!),
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
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
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
            const SizedBox(height: 32),
        
            if (!isLoadingStatistics && (userGenres != null || userRatingStats != null))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) => Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8D6748), Color(0xFF5D4037)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8D6748).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.analytics,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Reading Statistics ${DateTime.now().year}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    if (userGenres != null && userGenres!.isNotEmpty)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) => Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFF8E1), Color(0xFFF6E3B4)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE0C9A6), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8D6748).withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Most Read Genres',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color(0xFF5D4037),
                                      ),
                                    ),
                                    Text(
                                      '${DateTime.now().year}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF8D6748),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                             
                                Center(
                                  child: GenrePieChart(
                                    genres: userGenres!,
                                    size: 160,
                                  ),
                                ),
                                const SizedBox(height: 24),
                            
                                ...userGenres!.map((genre) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: GenreColors.getGenreColor(genre.genreName),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          genre.genreName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF5D4037),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${genre.percentage.toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF8D6748),
                                        ),
                                      ),
                                    ],
                                  ),
                                )).toList(),
                              ],
                            ),
                          ),
                        ),
                      )
                    ,
                    const SizedBox(height: 16),
                    
                    if (userRatingStats != null)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1400),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) => Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFF8E1), Color(0xFFF6E3B4)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE0C9A6), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8D6748).withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Average rating ${userRatingStats!.averageRating}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color(0xFF5D4037),
                                      ),
                                    ),
                                    Text(
                                      '${userRatingStats!.totalReviews} reviews',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF8D6748),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                             
                                ...userRatingStats!.ratingDistribution.entries.map((entry) {
                                  final rating = entry.key;
                                  final count = entry.value;
                                  final maxCount = userRatingStats!.ratingDistribution.values.reduce((a, b) => a > b ? a : b);
                                  final percentage = maxCount > 0 ? count / maxCount : 0.0;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          child: Row(
                                            children: [
                                              Text(
                                                rating.toString(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF8D6748),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.star,
                                                size: 12,
                                                color: Color(0xFF8D6748),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE0C9A6),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: percentage,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [Color(0xFF8D6748), Color(0xFF5D4037)],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 30,
                                          child: Text(
                                            count.toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF8D6748),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
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
}
