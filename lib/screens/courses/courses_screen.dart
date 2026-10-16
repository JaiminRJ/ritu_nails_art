import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../auth/widgets/course_payment_sheet.dart';
import '../common/subscription_dialog.dart';
import '../common/video_card.dart';
import 'add_course_or_video_screen.dart';

class CourseModel {
  final String title;
  final String category;
  final String level;
  final String price;
  final String imageUrl;
  final List<String> perks;
  final bool isOnline; // true: Online, false: Offline / In-Studio

  CourseModel({
    required this.title,
    required this.category,
    required this.level,
    required this.price,
    required this.imageUrl,
    required this.perks,
    this.isOnline = false,
  });
}

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  // 0: Offline / Studio, 1: Online Classes, 2: Video Clips
  int _selectedMode = 0;
  String _selectedCategory = 'All';

  // Toggle this based on user subscription state
  final bool _isSubscribed = false;

  final List<String> _filters = [
    'All',
    'Nail Art',
    'Makeup',
    'Hair Styling',
  ];

  // Video Tutorial Clips for Nails, Makeup & Hair
  final List<VideoTutorial> _videoTutorials = [
    // Nails
    VideoTutorial(
      id: 'nail_01',
      title: 'Russian Cuticle Prep & Builder Gel Overlay',
      category: 'Nail Art',
      duration: '',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=800&q=80',
      isPremium: true,
    ),
    VideoTutorial(
      id: 'nail_02',
      title: 'French Ombre & Mirror Chrome Application',
      category: 'Nail Art',
      duration: '',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1632345031435-8727f6897d53?w=800&q=80',
      isPremium: true,
    ),
    // Makeup
    VideoTutorial(
      id: 'makeup_01',
      title: 'HD Waterproof Bridal Base & Micro-Baking',
      category: 'Makeup',
      duration: '',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=800&q=80',
      isPremium: true,
    ),
    VideoTutorial(
      id: 'makeup_02',
      title: 'Soft Glam Eye Blending & Eyelash Fixation',
      category: 'Makeup',
      duration: '',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=800&q=80',
      isPremium: true,
    ),
    // Hair
    VideoTutorial(
      id: 'hair_01',
      title: 'Hollywood Waves & Wand Sectioning',
      category: 'Hair Styling',
      duration: '',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800&q=80',
      isPremium: true,
    ),
    VideoTutorial(
      id: 'hair_02',
      title: 'Bridal Textured Donut Bun & Extension Pinning',
      category: 'Hair Styling',
      duration: '',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?w=800&q=80',
      isPremium: true,
    ),
  ];

  final List<CourseModel> _courses = [
    CourseModel(
      title: 'Professional Nail Art & Extension Masterclass',
      category: 'Nail Art',
      level: 'Beginner to Pro',
      price: '₹14,999',
      isOnline: false,
      imageUrl:
          'https://images.unsplash.com/photo-1632345031435-8727f6897d53?w=800&q=80',
      perks: [
        'Gel & Acrylic extensions',
        'Free practice kit included',
        'Govt / Salon certified certificate',
      ],
    ),
    CourseModel(
      title: 'Online Nail Art & Design Masterclass',
      category: 'Nail Art',
      level: 'All Levels',
      price: '₹3,499',
      isOnline: true,
      imageUrl:
          'https://images.unsplash.com/photo-1632345031435-8727f6897d53?w=800&q=80',
      perks: [
        'Live interactive Zoom sessions',
        'Recorded access for 1 year',
        'Digital Certificate included',
      ],
    ),
    CourseModel(
      title: 'Advanced 3D & Ombre Nail Art Workshop',
      category: 'Nail Art',
      level: 'Advanced',
      price: '₹4,999',
      isOnline: false,
      imageUrl:
          'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=800&q=80',
      perks: [
        'Chrome, Cat-eye & 3D sculpting',
        'Live model demo',
        'Portfolio building session',
      ],
    ),
    CourseModel(
      title: 'HD Bridal Makeup & Vanity Setup',
      category: 'Makeup',
      level: 'All Levels',
      price: '₹24,999',
      isOnline: false,
      imageUrl:
          'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=800&q=80',
      perks: [
        'Skin undertone matching & color theory',
        'Bridal, Engagement & Cocktail looks',
        'Social media & client handling tips',
      ],
    ),
    CourseModel(
      title: 'Online Self-Makeup & Glam Masterclass',
      category: 'Makeup',
      level: 'Beginner',
      price: '₹1,999',
      isOnline: true,
      imageUrl:
          'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=800&q=80',
      perks: [
        'Day to night look transitions',
        'Product recommendations list',
        'Q&A doubt clearance sessions',
      ],
    ),
    CourseModel(
      title: 'Bridal Hair Styling & Contemporary Updos',
      category: 'Hair Styling',
      level: 'Intermediate',
      price: '₹9,999',
      isOnline: false,
      imageUrl:
          'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800&q=80',
      perks: [
        'Russian braids & messy buns',
        'Hair prep, teasing & extension pinning',
        'Accessory styling',
      ],
    ),
    CourseModel(
      title: 'Online Quick Hairstyles & Braid Patterns',
      category: 'Hair Styling',
      level: 'Beginner',
      price: '₹2,499',
      isOnline: true,
      imageUrl:
          'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800&q=80',
      perks: [
        '10+ Quick party hairstyles',
        'HD step-by-step videos',
        'Certificate of completion',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter regular courses
    final filteredCourses = _courses.where((c) {
      final matchesMode = (_selectedMode == 1) ? c.isOnline : !c.isOnline;
      final matchesCategory =
          _selectedCategory == 'All' || c.category == _selectedCategory;
      return matchesMode && matchesCategory;
    }).toList();

    // Filter video tutorials
    final filteredVideos = _videoTutorials.where((v) {
      return _selectedCategory == 'All' || v.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCourseOrVideoScreen(),
            ),
          );

          if (result != null && result is Map) {
            setState(() {
              if (result['type'] == 'course') {
                final newCourse = result['data'] as CourseModel;
                _courses.insert(0, newCourse);
                _selectedMode = newCourse.isOnline ? 1 : 0;
              } else if (result['type'] == 'video') {
                final newVideo = result['data'] as VideoTutorial;
                _videoTutorials.insert(0, newVideo);
                _selectedMode = 2;
              }
            });
          }
        },
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Academy Announcement Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.82),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Upgrade Your Skills 🎓',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Hands-on live practicals, certified diplomas, and kit assistance.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3-Option Mode Selector: Offline, Online, Video Clips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildModeTab(
                          index: 0,
                          title: 'Offline / Studio',
                          icon: Icons.storefront_outlined,
                        ),
                      ),
                      Expanded(
                        child: _buildModeTab(
                          index: 1,
                          title: 'Online Classes',
                          icon: Icons.laptop_chromebook,
                        ),
                      ),
                      Expanded(
                        child: _buildModeTab(
                          index: 2,
                          title: 'Video Clips',
                          icon: Icons.play_circle_outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Horizontal Filter Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedCategory == filter;
                    return ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        setState(() => _selectedCategory = filter);
                      },
                    );
                  },
                ),
              ),
            ),

            // Mode 2: Video Clips View
            if (_selectedMode == 2) ...[
              if (filteredVideos.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No video clips available in this category.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final video = filteredVideos[index];
                        return VideoCard(
                          video: video,
                          isSubscribed: _isSubscribed,
                          onWatch: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Playing ${video.title}')),
                            );
                          },
                          onRedirectPayment: () {
                            CoursePaymentSheet.show(
                              context,
                              courseTitle:
                                  "Masterclass Subscription (${video.title})",
                              amount: "₹499",
                            );
                          },
                        );
                      },
                      childCount: filteredVideos.length,
                    ),
                  ),
                ),
            ]
            // Modes 0 & 1: Offline / Online Course Cards
            else ...[
              if (filteredCourses.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No courses available in this category.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final course = filteredCourses[index];
                        return _buildCourseCard(course);
                      },
                      childCount: filteredCourses.length,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final bool isSelected = _selectedMode == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedMode = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Image with Level Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  course.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child:
                        const Icon(Icons.school, size: 48, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    course.level,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Course Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Key Highlights
                ...course.perks.map(
                  (perk) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            perk,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Price and Payment Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Fee',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          course.price,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        CoursePaymentSheet.show(
                          context,
                          courseTitle: course.title,
                          amount: course.price,
                        );
                      },
                      child: const Text(
                        'Apply Now',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}