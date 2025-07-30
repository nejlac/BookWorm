import 'package:flutter/material.dart';
import '../model/user.dart';
import '../model/country.dart';
import '../model/challenge.dart';
import '../providers/country_provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/base_provider.dart';
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
  Country? _userCountry;
  Challenge? _userChallenge;
  bool _isLoadingChallenge = false;

  @override
  void initState() {
    super.initState();
    _loadUserCountry();
    _loadUserChallenge();
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
      
      // Get the selected user's challenge by their username
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
      print('Error loading user challenge: $e');
      setState(() {
        _isLoadingChallenge = false;
      });
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
                    // No challenge - show message
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
                    // Has challenge - show progress
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
} 