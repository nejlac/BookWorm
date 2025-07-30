import 'package:flutter/material.dart';
import 'package:bookworm_mobile/model/challenge.dart';
import 'package:bookworm_mobile/providers/challenge_provider.dart';
import 'package:bookworm_mobile/providers/auth_provider.dart';
import 'package:bookworm_mobile/providers/book_provider.dart';
import 'package:bookworm_mobile/screens/book_details.dart';

class ChallengeDetailsScreen extends StatefulWidget {
  final Challenge challenge;

  const ChallengeDetailsScreen({Key? key, required this.challenge}) : super(key: key);

  @override
  State<ChallengeDetailsScreen> createState() => _ChallengeDetailsScreenState();
}

class _ChallengeDetailsScreenState extends State<ChallengeDetailsScreen> {
  Challenge? currentChallenge;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChallengeDetails();
  }

  Future<void> _loadChallengeDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Use the passed challenge data directly since we already have the correct challenge
      // from the user profile screen
      setState(() {
        currentChallenge = widget.challenge;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading challenge details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _viewBookDetails(int bookId) async {
    try {
      final bookProvider = BookProvider();
      final book = await bookProvider.getById(bookId);
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(book: book),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading book details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = currentChallenge ?? widget.challenge;
    final progress = challenge.goal > 0 
        ? (challenge.numberOfBooksRead / challenge.goal).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8D6748),
        foregroundColor: Colors.white,
        elevation: 2,
        title: Text('Challenge ${challenge.year}'),
        actions: [],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8D6748)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Challenge Progress Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6E3B4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE0C9A6), width: 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 10,
                                    backgroundColor: const Color(0xFFE0C9A6),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8D6748)),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${challenge.numberOfBooksRead}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: Color(0xFF5D4037),
                                      ),
                                    ),
                                    Text(
                                      'of ${challenge.goal}',
                                      style: const TextStyle(
                                        fontSize: 14,
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
                                    challenge.isCompleted 
                                        ? 'Challenge Completed! 🎉'
                                        : 'Reading Progress',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: challenge.isCompleted 
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFF5D4037),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    challenge.isCompleted
                                        ? 'Congratulations! You\'ve reached your goal of ${challenge.goal} books.'
                                        : 'You have read ${challenge.numberOfBooksRead} out of ${challenge.goal} books this year.\nKeep going until you reach your goal!',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF8D6748),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Progress: ${((challenge.numberOfBooksRead / challenge.goal) * 100).toStringAsFixed(1)}%',
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your challenge automatically counts books from your "Read" list that were read this year. No need to manually add books!',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Books Section
                  Row(
                    children: [
                      const Icon(Icons.book, color: Color(0xFF8D6748), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Completed Books (${challenge.books.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (challenge.books.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6E3B4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0C9A6), width: 1),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.book_outlined,
                            size: 48,
                            color: Color(0xFF8D6748),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No books completed yet',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your challenge automatically counts books from your "Read" list that were read this year.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8D6748),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: challenge.books.length,
                      itemBuilder: (context, index) {
                        final book = challenge.books[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE0C9A6), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF4CAF50),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF5D4037),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Completed: ${book.completedAt.day}/${book.completedAt.month}/${book.completedAt.year}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8D6748),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Color(0xFF8D6748)),
                                onSelected: (value) async {
                                  if (value == 'view') {
                                    // Navigate to book details
                                    _viewBookDetails(book.bookId);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'view',
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility, color: Color(0xFF8D6748)),
                                        SizedBox(width: 8),
                                        Text('View Details'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
} 