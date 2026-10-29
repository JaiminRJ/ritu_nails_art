import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../services/course_api_service.dart';

class AddCourseOrVideoScreen extends StatefulWidget {
  const AddCourseOrVideoScreen({super.key});

  @override
  State<AddCourseOrVideoScreen> createState() =>
      _AddCourseOrVideoScreenState();
}

class _AddCourseOrVideoScreenState extends State<AddCourseOrVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  int _selectedMode = 0;
  String _selectedCategory = 'Nail Art';
  String _selectedLevel = 'Beginner to Pro';

  // Image
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  // Video - Web compatible
  Uint8List? _selectedVideoBytes;
  String? _selectedVideoName;

  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceController = TextEditingController();
  final _videoUrlController = TextEditingController();

  bool _isPremiumVideo = true;

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

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = pickedFile.name;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not select image: ${error.message}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not select image: $error',
          ),
        ),
      );
    }
  }

  // ============================================================
  // PICK VIDEO - WEB COMPATIBLE
  // ============================================================

  Future<void> _pickVideo() async {
    try {
      final pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return;

      // IMPORTANT:
      // Do NOT use pickedFile.path.
      // Flutter Web does not support native file paths.
      final bytes = await pickedFile.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedVideoBytes = bytes;
        _selectedVideoName = pickedFile.name;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not select video: ${error.message}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not select video: $error',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SAVE ITEM
  // ============================================================

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    // Video validation
    if (_selectedMode == 2 &&
        _selectedVideoBytes == null &&
        _videoUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a video file or enter a video URL.',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      Map<String, dynamic> response;

      // ========================================================
      // VIDEO CLIP
      // ========================================================

      if (_selectedMode == 2) {
        response = await CourseApiService.uploadVideoClip(
          title: _titleController.text.trim(),
          category: _selectedCategory,
          isPremium: _isPremiumVideo,

          thumbnailUrl: _imageUrlController.text.trim(),
          videoUrl: _videoUrlController.text.trim(),

          thumbnailBytes: _selectedImageBytes,
          thumbnailFilename: _selectedImageName ??
              'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg',

          // Web-compatible video upload
          localVideoBytes: _selectedVideoBytes,
          localVideoFilename: _selectedVideoName,
        );
      }

      // ========================================================
      // COURSE
      // ========================================================

      else {
        final perks = _perkControllers
            .map((c) => c.text.trim())
            .where((p) => p.isNotEmpty)
            .toList();

        final cleanPrice = double.tryParse(
              _priceController.text
                  .replaceAll('₹', '')
                  .replaceAll(',', '')
                  .trim(),
            ) ??
            0.0;

        response = await CourseApiService.uploadCourse(
          title: _titleController.text.trim(),
          category: _selectedCategory,
          level: _selectedLevel,
          price: cleanPrice,
          isOnline: _selectedMode == 1,
          perks: perks.isEmpty
              ? ['Certificate included']
              : perks,
          imageUrl: _imageUrlController.text.trim(),
          imageBytes: _selectedImageBytes,
          filename: _selectedImageName ??
              'course_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // ========================================================
      // SUCCESS
      // ========================================================

      if (response['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ??
                  'Published successfully!',
            ),
          ),
        );

        Navigator.pop(context, true);
      }

      // ========================================================
      // ERROR
      // ========================================================

      else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ??
                  'Failed to publish details',
            ),
          ),
        );
      }
    } catch (error) {
      // Make sure loading dialog is closed
      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Something went wrong: $error',
            ),
          ),
        );
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isVideoMode = _selectedMode == 2;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'Add New Item',
          style: TextStyle(
            fontFamily: 'cursive',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ==================================================
              // MODE SELECTOR
              // ==================================================

              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildModeButton(
                      0,
                      'Offline',
                      Icons.storefront_outlined,
                    ),
                    _buildModeButton(
                      1,
                      'Online',
                      Icons.laptop_chromebook,
                    ),
                    _buildModeButton(
                      2,
                      'Video Clip',
                      Icons.play_circle_outline,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // TITLE
              // ==================================================

              _buildLabel(
                isVideoMode
                    ? 'Video Title *'
                    : 'Course Title *',
              ),

              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration(
                  hint: isVideoMode
                      ? 'e.g. Russian Cuticle Prep & Builder Gel'
                      : 'e.g. Professional Nail Art & Extension Masterclass',
                  icon: Icons.title,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Enter a title';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // CATEGORY + LEVEL
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Category *'),

                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: _inputDecoration(),

                          items: _categories.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            );
                          }).toList(),

                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCategory = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  if (!isVideoMode) ...[
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Skill Level *'),

                          DropdownButtonFormField<String>(
                            initialValue: _selectedLevel,
                            decoration: _inputDecoration(),

                            items: _levels.map((l) {
                              return DropdownMenuItem(
                                value: l,
                                child: Text(l),
                              );
                            }).toList(),

                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedLevel = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // COURSE PRICE
              // ==================================================

              if (!isVideoMode) ...[
                _buildLabel('Course Fee *'),

                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,

                  decoration: _inputDecoration(
                    hint: '0.00 /-',
                    icon: Icons.currency_rupee,
                  ),

                  validator: (val) {
                    if (val == null ||
                        val.trim().isEmpty) {
                      return 'Enter price';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),
              ],

              // ==================================================
              // COVER IMAGE / THUMBNAIL
              // ==================================================

              _buildLabel('Cover Image / Thumbnail'),

              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(
                  Icons.photo_library_outlined,
                ),
                label: Text(
                  _selectedImageBytes == null
                      ? 'Choose Image'
                      : 'Change Image',
                ),
              ),

              if (_selectedImageBytes != null) ...[
                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),

                  child: Image.memory(
                    _selectedImageBytes!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],

              const SizedBox(height: 8),

              TextFormField(
                controller: _imageUrlController,

                decoration: _inputDecoration(
                  hint:
                      'Or enter image URL: https://images.unsplash.com/...',
                  icon: Icons.image_outlined,
                ),
              ),

              // ==================================================
              // VIDEO SECTION
              // ==================================================

              if (isVideoMode) ...[
                const SizedBox(height: 16),

                _buildLabel(
                  'Video Stream Link or File URL',
                ),

                TextFormField(
                  controller: _videoUrlController,

                  decoration: _inputDecoration(
                    hint:
                        'https://example.com/video.mp4',
                    icon: Icons.link,
                  ),
                ),

                const SizedBox(height: 8),

                // ================================================
                // VIDEO PICKER
                // ================================================

                OutlinedButton.icon(
                  onPressed: _pickVideo,

                  icon: const Icon(
                    Icons.video_library_outlined,
                  ),

                  label: Text(
                    _selectedVideoName == null
                        ? 'Choose Local Video Clip'
                        : 'Change Local Video Clip',
                  ),
                ),

                // ================================================
                // SELECTED VIDEO NAME
                // ================================================

                if (_selectedVideoName != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 4),

                    child: Text(
                      'Selected: $_selectedVideoName',

                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // ================================================
                // PREMIUM SWITCH
                // ================================================

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,

                  activeThumbColor: AppColors.primary,

                  title: const Text(
                    'Premium Locked Clip',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),

                  subtitle: const Text(
                    'Requires user subscription to watch',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  value: _isPremiumVideo,

                  onChanged: (val) {
                    setState(() {
                      _isPremiumVideo = val;
                    });
                  },
                ),
              ],

              // ==================================================
              // COURSE PERKS
              // ==================================================

              if (!isVideoMode) ...[
                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    _buildLabel(
                      'Key Highlights / Perks',
                    ),

                    TextButton.icon(
                      onPressed: _addPerkField,

                      icon: const Icon(
                        Icons.add,
                        size: 16,
                      ),

                      label: const Text(
                        'Add Perk',
                      ),

                      style: TextButton.styleFrom(
                        foregroundColor:
                            AppColors.primary,
                      ),
                    ),
                  ],
                ),

                ..._perkControllers
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final ctrl = entry.value;

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 8.0,
                    ),

                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ctrl,

                            decoration:
                                _inputDecoration(
                              hint:
                                  'e.g. Kit included / Certification',
                              icon: Icons
                                  .check_circle_outline,
                            ),
                          ),
                        ),

                        if (_perkControllers.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
                            ),

                            onPressed: () =>
                                _removePerkField(
                              index,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 32),

              // ==================================================
              // SAVE BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: _saveItem,

                  child: Text(
                    isVideoMode
                        ? 'Save Video Clip'
                        : 'Publish Course',

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

  // ============================================================
  // MODE BUTTON
  // ============================================================

  Widget _buildModeButton(
    int index,
    String title,
    IconData icon,
  ) {
    final bool isSelected =
        _selectedMode == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMode = index;
          });
        },

        borderRadius:
            BorderRadius.circular(9),

        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200),

          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : Colors.transparent,

            borderRadius:
                BorderRadius.circular(9),
          ),

          alignment: Alignment.center,

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? Colors.white
                    : Colors.black54,
              ),

              const SizedBox(width: 4),

              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.black87,

                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.w500,

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

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 6.0),

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

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: icon != null
          ? Icon(
              icon,
              size: 20,
              color: Colors.grey,
            )
          : null,

      filled: true,
      fillColor: Colors.white,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),

        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),

        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),

        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }
}