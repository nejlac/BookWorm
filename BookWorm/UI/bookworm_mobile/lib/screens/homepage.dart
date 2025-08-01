import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/reading_streak_provider.dart';
import '../model/user.dart';
import '../model/reading_streak.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser;
  ReadingStreak? readingStreak;
  bool isLoading = true;
  bool isMarkingActivity = false;

  @override
  void initState() {
    super.initState();
    _loadUserAndStreak();
  }

  Future<void> _loadUserAndStreak() async {
    final username = AuthProvider.username;
    if (username == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final userProvider = UserProvider();
      final userResult = await userProvider.get(filter: {'username': username, 'pageSize': 1});
      final user = userResult.items != null && userResult.items!.isNotEmpty ? userResult.items!.first : null;
      
      if (user != null) {
        setState(() {
          currentUser = user;
        });

        final streakProvider = ReadingStreakProvider();
        final streak = await streakProvider.getUserStreak(user.id);
        
        setState(() {
          readingStreak = streak ?? ReadingStreak(
            id: 0,
            userId: user.id,
            userName: user.username,
            currentStreak: 0,
            longestStreak: 0,
            lastReadingDate: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActiveToday: false,
            daysSinceLastReading: 1,
          );
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user and streak: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _markReadingActivity() async {
    if (currentUser == null) return;

    setState(() {
      isMarkingActivity = true;
    });

    try {
      final streakProvider = ReadingStreakProvider();
      final updatedStreak = await streakProvider.markReadingActivity(currentUser!.id);
      
      setState(() {
        readingStreak = updatedStreak;
        isMarkingActivity = false;
      });

      _showCelebrationEffect();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  readingStreak!.currentStreak == 1 
                      ? '🎉 First day of your reading streak! Keep going!'
                      : '🎉 Awesome! Your streak is now ${readingStreak!.currentStreak} days!',
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      setState(() {
        isMarkingActivity = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking reading activity: $e'),
          backgroundColor: const Color(0xFFF44336),
        ),
      );
    }
  }

  void _showCelebrationEffect() {
    setState(() {
    
    });
  }

  String _getStreakMessage() {
    if (readingStreak == null) return 'Start your reading journey today!';
    
    if (readingStreak!.currentStreak == 0) {
      return 'Start your reading streak today!';
    } else if (readingStreak!.currentStreak == 1) {
      return 'Great start! Keep reading to build your streak!';
    } else if (readingStreak!.currentStreak < 7) {
      return 'You\'re building a great habit! Keep it up!';
    } else if (readingStreak!.currentStreak < 30) {
      return 'Amazing dedication! You\'re on fire!';
    } else {
      return 'Incredible! You\'re a reading champion!';
    }
  }

  Color _getStreakColor() {
    if (readingStreak == null || readingStreak!.currentStreak == 0) {
      return const Color(0xFF8D6748);
    } else if (readingStreak!.currentStreak < 7) {
      return const Color(0xFF4CAF50);
    } else if (readingStreak!.currentStreak < 30) {
      return const Color(0xFFFF9800);
    } else {
      return const Color(0xFFE91E63);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF8E1), Color(0xFFF6E3B4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Reading streak',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF5D4037),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: readingStreak?.currentStreak.toDouble() ?? 0.0),
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.elasticOut,
                                  builder: (context, value, child) => Text(
                                    '${value.toInt()} days',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      color: _getStreakColor(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getStreakMessage(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF8D6748),
                                  ),
                                ),
                                if (readingStreak != null && readingStreak!.longestStreak > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Longest streak: ${readingStreak!.longestStreak} days',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8D6748),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (readingStreak != null && readingStreak!.isActiveToday)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '✓ Today',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (readingStreak == null || !readingStreak!.isActiveToday)
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: isMarkingActivity ? null : _markReadingActivity,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              elevation: 3,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: isMarkingActivity
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.book, size: 18),
                            label: isMarkingActivity
                                ? const Text(
                                    'Marking...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  )
                                : const Text(
                                    'I Read Today! 📚',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
         
        ],
      ),
    );
  }
}
