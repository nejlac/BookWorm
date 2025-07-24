import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              color: const Color(0xFFFFF8E1),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Reading streak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF5D4037))),
                        SizedBox(height: 6),
                        Text('45 days', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFFB87333))),
                        SizedBox(height: 4),
                        Text('You have been reading constantly for 45 days.\nDon\'t lose your streak!', style: TextStyle(fontSize: 13, color: Color(0xFF8D6748))),
                        SizedBox(height: 10),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          // ... (add more widgets below as needed)
        ],
      ),
    );
  }
}