import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FeedbackListScreen extends StatelessWidget {
  const FeedbackListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with dynamic items from your ApiService if connected
    final List<Map<String, dynamic>> dummyFeedbacks = [
      {'user': 'Ananya S.', 'rating': 5, 'comment': 'Loved the chrome nail extensions! Super clean studio.', 'date': 'Yesterday'},
      {'user': 'Pooja K.', 'rating': 5, 'comment': 'Bridal makeup was flawless throughout the entire wedding event.', 'date': '3 days ago'},
      {'user': 'Sneha M.', 'rating': 4, 'comment': 'Great nail art training session. Very patient instructor.', 'date': '1 week ago'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Feedback List',
          style: TextStyle(
            fontFamily: 'cursive',
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: dummyFeedbacks.isEmpty
          ? const Center(child: Text('No feedback entries found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dummyFeedbacks.length,
              itemBuilder: (context, index) {
                final item = dummyFeedbacks[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['user'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(item['date'], style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          item['rating'],
                          (_) => const Icon(Icons.star, color: Colors.amber, size: 16),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(item['comment'], style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}