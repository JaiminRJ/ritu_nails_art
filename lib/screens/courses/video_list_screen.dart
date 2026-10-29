import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../common/video_card.dart';
import '../auth/widgets/course_payment_sheet.dart'; // Uses your existing payment sheet

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  // Toggle this according to your user authentication/subscription state
  bool isStudentSubscribed = false;

  final List<VideoTutorial> allVideos = [
    // Nails
    VideoTutorial(
      id: 'nail_01',
      title: 'Russian Cuticle Prep & Builder Gel Overlay',
      category: 'Nails',
      duration: '14:20',
      thumbnailUrl: 'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=500',
      isPremium: true,
    ),
    VideoTutorial(
      id: 'nail_02',
      title: 'French Ombre & Mirror Chrome Powder Application',
      category: 'Nails',
      duration: '16:05',
      thumbnailUrl: 'https://images.unsplash.com/photo-1632345031435-8727f6897d53?w=500',
      isPremium: true,
    ),
    // Makeup
    VideoTutorial(
      id: 'makeup_01',
      title: 'Waterproof HD Bridal Base & Micro-Baking',
      category: 'Makeup',
      duration: '22:15',
      thumbnailUrl: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=500',
      isPremium: true,
    ),
    VideoTutorial(
      id: 'makeup_02',
      title: 'Soft Glam Eye Blending & Eyelash Application',
      category: 'Makeup',
      duration: '19:40',
      thumbnailUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=500',
      isPremium: true,
    ),
    // Hair
    VideoTutorial(
      id: 'hair_01',
      title: 'Bollywood Hollywood Waves & Wand Direction',
      category: 'Hair',
      duration: '18:30',
      thumbnailUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=500',
      isPremium: true,
    ),
    VideoTutorial(
      id: 'hair_02',
      title: 'Bridal Textured Donut Bun & Extension Placement',
      category: 'Hair',
      duration: '24:10',
      thumbnailUrl: 'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?w=500',
      isPremium: true,
    ),
  ];

  void _openPaymentSheet(VideoTutorial video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CoursePaymentSheet(
        courseTitle: video.title,
        amount: "₹499", // Or your desired subscription / course price
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Video Masterclasses',
            style: TextStyle(
              fontFamily: 'cursive',
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "All"),
              Tab(text: "Nails"),
              Tab(text: "Makeup"),
              Tab(text: "Hair"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildVideoListView(allVideos),
            _buildVideoListView(allVideos.where((v) => v.category == 'Nails').toList()),
            _buildVideoListView(allVideos.where((v) => v.category == 'Makeup').toList()),
            _buildVideoListView(allVideos.where((v) => v.category == 'Hair').toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoListView(List<VideoTutorial> list) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final video = list[index];
        return VideoCard(
          video: video,
          isSubscribed: isStudentSubscribed,
          onWatch: () {
            // Open video player route
            Navigator.pushNamed(context, '/player', arguments: video.id);
          },
          onRedirectPayment: () => _openPaymentSheet(video),
        );
      },
    );
  }
}