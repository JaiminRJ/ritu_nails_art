import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';


class PortfolioGalleryScreen extends StatefulWidget {
  final String serviceType; // 'Nails', 'Makeup', or 'Hair'

  const PortfolioGalleryScreen({
    super.key,
    required this.serviceType,
  });

  @override
  State<PortfolioGalleryScreen> createState() => _PortfolioGalleryScreenState();
}

class _PortfolioGalleryScreenState extends State<PortfolioGalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  List<NailPortfolioItem> _portfolio = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> _categories = [
    {'id': 0, 'name': 'All'}
  ];
  String _selectedFilter = 'All';

  String get _imageHost {
    if (!kIsWeb && Platform.isAndroid) {
      return 'https://10.0.2.2:7276';
    }
    return 'https://localhost:7276';
  }

  String get _categoryPlaceholder {
    switch (widget.serviceType.toLowerCase()) {
      case 'makeup':
        return 'e.g. Bridal HD, Party Glam, Editorial';
      case 'hair':
        return 'e.g. Bridal Bun, Soft Curls, Braids';
      default:
        return 'e.g. Ombre, Gel, 3D Art';
    }
  }

  String get _titlePlaceholder {
    switch (widget.serviceType.toLowerCase()) {
      case 'makeup':
        return 'e.g. Royal Bridal Look';
      case 'hair':
        return 'e.g. Traditional Floral Bun';
      default:
        return 'e.g. Glitter French Ombre';
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(covariant PortfolioGalleryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serviceType != widget.serviceType) {
      _selectedFilter = 'All';
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadCategories(),
      _loadPortfolioData(showSpinner: false),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    final fetched = await ApiService.fetchCategories(serviceType: widget.serviceType);
    if (mounted) {
      setState(() {
        _categories = [
          {'id': 0, 'name': 'All'},
          ...fetched.map((c) => {'id': c['id'] ?? 0, 'name': c['name'] ?? ''}),
        ];
      });
    }
  }

  Future<void> _loadPortfolioData({int? categoryId, bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() => _isLoading = true);
    }

    final items = await ApiService.fetchNailArts(
      categoryId: categoryId,
      serviceType: widget.serviceType,
    );

    if (mounted) {
      setState(() {
        _portfolio = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final TextEditingController catController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Add ${widget.serviceType} Category',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: TextField(
                controller: catController,
                autofocus: true,
                enabled: !isSubmitting,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  hintText: _categoryPlaceholder,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final name = catController.text.trim();
                          if (name.isEmpty) return;

                          setDialogState(() => isSubmitting = true);

                          final result = await ApiService.createCategory(
                            name,
                            serviceType: widget.serviceType,
                          );

                          if (!mounted) return;

                          if (result['success'] == true) {
                            Navigator.pop(dialogContext);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ?? 'Category added successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            await _loadCategories();
                          } else {
                            setDialogState(() => isSubmitting = false);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ?? 'Failed to add category'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showUploadDialog() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final Uint8List bytes = await pickedFile.readAsBytes();
    final String filename = pickedFile.name;
    final TextEditingController titleController = TextEditingController();
    final TextEditingController priceController = TextEditingController(text: '0');
    final TextEditingController descController = TextEditingController();

    final validCategories = _categories.where((c) => (c['id'] as int) != 0).toList();
    int chosenCategoryId = validCategories.isNotEmpty ? (validCategories.first['id'] as int) : 1;

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        bool isUploading = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Upload ${widget.serviceType} Work',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        bytes,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title / Style Name',
                        hintText: _titlePlaceholder,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: chosenCategoryId,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: validCategories
                          .map(
                            (c) => DropdownMenuItem<int>(
                              value: c['id'] as int,
                              child: Text(c['name'] as String),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => chosenCategoryId = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Price',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: isUploading
                          ? null
                          : () async {
                              final title = titleController.text.trim();
                              if (title.isEmpty) {
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Please enter a title')),
                                );
                                return;
                              }

                              setModalState(() => isUploading = true);

                              final result = await ApiService.uploadNailArt(
                                title: title,
                                categoryId: chosenCategoryId,
                                imageBytes: bytes,
                                filename: filename,
                                price: double.tryParse(priceController.text.trim()) ?? 0.0,
                                description: descController.text.trim(),
                                serviceType: widget.serviceType,
                              );

                              if (!mounted) return;

                              if (result['success'] == true) {
                                Navigator.pop(bottomSheetContext);
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] as String),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                final currentCat = _categories.firstWhere(
                                  (c) => c['name'] == _selectedFilter,
                                  orElse: () => {'id': 0},
                                );
                                final int? catId = currentCat['id'] == 0 ? null : currentCat['id'] as int;
                                _loadPortfolioData(categoryId: catId);
                              } else {
                                setModalState(() => isUploading = false);
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] as String),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      icon: isUploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.cloud_upload_outlined),
                      label: Text(isUploading ? 'Uploading...' : 'Add to ${widget.serviceType}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Category Filter Pills
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: InkWell(
                      onTap: _showAddCategoryDialog,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.black87, size: 20),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 16),
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final String name = cat['name'] as String;
                        final int id = cat['id'] as int;
                        final isSelected = _selectedFilter == name;

                        return ChoiceChip(
                          label: Text(name),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : Colors.grey.shade300,
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() => _selectedFilter = name);
                            _loadPortfolioData(categoryId: id == 0 ? null : id);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Portfolio Items Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _portfolio.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No ${widget.serviceType.toLowerCase()} designs uploaded yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap the button below to upload your first work',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            final currentCat = _categories.firstWhere(
                              (c) => c['name'] == _selectedFilter,
                              orElse: () => {'id': 0},
                            );
                            final int? catId = currentCat['id'] == 0 ? null : currentCat['id'] as int;
                            await _loadPortfolioData(categoryId: catId, showSpinner: false);
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: _portfolio.length,
                            itemBuilder: (context, index) {
                              return _buildPortfolioCard(_portfolio[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: Text('Upload ${widget.serviceType}'),
      ),
    );
  }

 Widget _buildPortfolioCard(NailPortfolioItem item) {
  String fullImageUrl = item.imageUrl;
  if (!fullImageUrl.startsWith('http')) {
    final cleanPath = item.imageUrl.startsWith('/') 
        ? item.imageUrl 
        : '/${item.imageUrl}';
    fullImageUrl = '$_imageHost$cleanPath';
  }

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              fullImageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              // Headers help bypass some local CORS caching in web
              headers: const {'Accept': '*/*'},
              errorBuilder: (context, error, stackTrace) {
                // If it fails, print the exact error and url to the console
                debugPrint('❌ Image failed to load: $fullImageUrl');
                debugPrint('❌ Error details: $error');
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.categoryName,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (item.price > 0)
                    Text(
                      '₹${NumberFormat('#,##0').format(item.price)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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