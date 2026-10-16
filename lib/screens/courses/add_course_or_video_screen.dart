import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../common/video_card.dart';
import 'courses_screen.dart';

class AddCourseOrVideoScreen extends StatefulWidget {
  const AddCourseOrVideoScreen({super.key});

  @override
  State<AddCourseOrVideoScreen> createState() => _AddCourseOrVideoScreenState();
}

class _AddCourseOrVideoScreenState extends State<AddCourseOrVideoScreen> {
  final _formKey = GlobalKey<FormState>();

  // 0: Offline, 1: Online, 2: Video Clips
  int _selectedMode = 0;
  String _selectedCategory = 'Nail Art';
  String _selectedLevel = 'Beginner to Pro';

  // Common Controllers
  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceController = TextEditingController();

  // Video-Specific Controllers
  final _videoUrlController = TextEditingController();
  bool _isPremiumVideo = true;

  // Perks / Highlights Controllers (for Courses)
  final List<TextEditingController> _perkControllers = [
    TextEditingController(text: 'Hands-on practical training'),
    TextEditingController(text: 'Certificate of completion'),
  ];

  final List<String> _categories = [
    'Nail Art',
    'Makeup',
    'Hair Styling',
  ];

  final List<String> _levels = [
    'Beginner to Pro',
    'Beginner',
    'Intermediate',
    'Advanced',
    'All Levels',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _videoUrlController.dispose();
    for (var c in _perkControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addPerkField() {
    setState(() {
      _perkControllers.add(TextEditingController());
    });
  }

  void _removePerkField(int index) {
    if (_perkControllers.length > 1) {
      setState(() {
        _perkControllers[index].dispose();
        _perkControllers.removeAt(index);
      });
    }
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMode == 2) {
      // Create new Video Clip
      final newVideo = VideoTutorial(
        id: 'vid_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        category: _selectedCategory,
        duration: '',
        thumbnailUrl: _imageUrlController.text.trim().isEmpty
            ? 'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=800&q=80'
            : _imageUrlController.text.trim(),
        isPremium: _isPremiumVideo,
      );
      Navigator.pop(context, {'type': 'video', 'data': newVideo});
    } else {
      // Create Offline or Online Course (No duration parameter)
      final perks = _perkControllers
          .map((c) => c.text.trim())
          .where((p) => p.isNotEmpty)
          .toList();

      final newCourse = CourseModel(
        title: _titleController.text.trim(),
        category: _selectedCategory,
        level: _selectedLevel,
        price: _priceController.text.startsWith('₹')
            ? _priceController.text.trim()
            : '₹${_priceController.text.trim()}',
        isOnline: _selectedMode == 1,
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? 'https://images.unsplash.com/photo-1632345031435-8727f6897d53?w=800&q=80'
            : _imageUrlController.text.trim(),
        perks: perks.isEmpty ? ['Certificate included'] : perks,
      );
      Navigator.pop(context, {'type': 'course', 'data': newCourse});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isVideoMode = _selectedMode == 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Add New Item',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Switcher for 3 Modes
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildModeButton(0, 'Offline', Icons.storefront_outlined),
                    _buildModeButton(1, 'Online', Icons.laptop_chromebook),
                    _buildModeButton(2, 'Video Clip', Icons.play_circle_outline),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title
              _buildLabel(isVideoMode ? 'Video Title *' : 'Course Title *'),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration(
                  hint: isVideoMode
                      ? 'e.g. Russian Cuticle Prep & Builder Gel'
                      : 'e.g. Professional Nail Art & Extension Masterclass',
                  icon: Icons.title,
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter a title' : null,
              ),

              const SizedBox(height: 16),

              // Category & Level Dropdowns
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Category *'),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: _inputDecoration(),
                          items: _categories.map((c) {
                            return DropdownMenuItem(value: c, child: Text(c));
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val!),
                        ),
                      ],
                    ),
                  ),
                  if (!isVideoMode) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Skill Level *'),
                          DropdownButtonFormField<String>(
                            value: _selectedLevel,
                            decoration: _inputDecoration(),
                            items: _levels.map((l) {
                              return DropdownMenuItem(value: l, child: Text(l));
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedLevel = val!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Course Fee (only for Offline & Online Courses)
              if (!isVideoMode) ...[
                _buildLabel('Course Fee *'),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    hint: '14,999',
                    icon: Icons.currency_rupee,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Enter price'
                      : null,
                ),
                const SizedBox(height: 16),
              ],

              // Cover Image URL
              _buildLabel('Cover Image / Thumbnail URL'),
              TextFormField(
                controller: _imageUrlController,
                decoration: _inputDecoration(
                  hint: 'https://images.unsplash.com/...',
                  icon: Icons.image_outlined,
                ),
              ),

              // Video-Specific Link & Premium Toggle
              if (isVideoMode) ...[
                const SizedBox(height: 16),
                _buildLabel('Video Stream Link or File URL'),
                TextFormField(
                  controller: _videoUrlController,
                  decoration: _inputDecoration(
                    hint: 'https://example.com/video.mp4',
                    icon: Icons.link,
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  title: const Text(
                    'Premium Locked Clip',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Requires user subscription to watch',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  value: _isPremiumVideo,
                  onChanged: (val) => setState(() => _isPremiumVideo = val),
                ),
              ],

              // Course Perks / Highlights
              if (!isVideoMode) ...[
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Key Highlights / Perks'),
                    TextButton.icon(
                      onPressed: _addPerkField,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Perk'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                ..._perkControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ctrl = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ctrl,
                            decoration: _inputDecoration(
                              hint: 'e.g. Kit included / Certification',
                              icon: Icons.check_circle_outline,
                            ),
                          ),
                        ),
                        if (_perkControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.redAccent),
                            onPressed: () => _removePerkField(index),
                          ),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 32),

              // Save Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveItem,
                  child: Text(
                    isVideoMode ? 'Save Video Clip' : 'Publish Course',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(int index, String title, IconData icon) {
    final bool isSelected = _selectedMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}