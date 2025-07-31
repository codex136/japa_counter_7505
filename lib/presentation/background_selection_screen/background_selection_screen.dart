import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/background_context_menu.dart';
import './widgets/background_grid_item.dart';
import './widgets/background_preview_dialog.dart';
import './widgets/custom_image_card.dart';
import './widgets/search_bar_widget.dart';

class BackgroundSelectionScreen extends StatefulWidget {
  const BackgroundSelectionScreen({super.key});

  @override
  State<BackgroundSelectionScreen> createState() => _BackgroundSelectionScreenState();
}

class _BackgroundSelectionScreenState extends State<BackgroundSelectionScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  
  String _currentBackground = '';
  List<String> _customImages = [];
  List<String> _filteredBackgrounds = [];
  bool _isLoading = false;
  String _searchQuery = '';
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Curated spiritual backgrounds
  final List<Map<String, dynamic>> _spiritualBackgrounds = [
{ "url": "https://images.pexels.com/photos/1051838/pexels-photo-1051838.jpeg",
"tags": ["temple", "spiritual", "architecture", "golden"] },
{ "url": "https://images.unsplash.com/photo-1544735716-392fe2489ffa",
"tags": ["lotus", "flower", "meditation", "pink", "water"] },
{ "url": "https://images.pexels.com/photos/1051449/pexels-photo-1051449.jpeg",
"tags": ["sunrise", "temple", "silhouette", "peaceful"] },
{ "url": "https://images.pixabay.com/photo/2017/08/06/12/06/people-2592247_1280.jpg",
"tags": ["meditation", "sunset", "peace", "spiritual"] },
{ "url": "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
"tags": ["mountain", "sunrise", "nature", "peaceful"] },
{ "url": "https://images.pexels.com/photos/1051838/pexels-photo-1051838.jpeg",
"tags": ["ganga", "river", "spiritual", "evening"] },
{ "url": "https://images.pixabay.com/photo/2018/01/14/23/12/nature-3082832_1280.jpg",
"tags": ["forest", "green", "nature", "calm"] },
{ "url": "https://images.unsplash.com/photo-1518709268805-4e9042af2176",
"tags": ["abstract", "spiritual", "mandala", "pattern"] },
{ "url": "https://images.pexels.com/photos/1051838/pexels-photo-1051838.jpeg",
"tags": ["deity", "spiritual", "traditional", "colorful"] },
{ "url": "https://images.pixabay.com/photo/2016/11/29/05/45/astronomy-1867616_1280.jpg",
"tags": ["stars", "night", "cosmic", "meditation"] },
{ "url": "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
"tags": ["ocean", "waves", "blue", "calm"] },
{ "url": "https://images.pexels.com/photos/1051449/pexels-photo-1051449.jpeg",
"tags": ["candle", "flame", "meditation", "light"] }
];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSavedData();
    _filteredBackgrounds = _spiritualBackgrounds.map((bg) => bg["url"] as String).toList();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentBackground = prefs.getString('background_image_path') ?? '';
        _customImages = prefs.getStringList('custom_images') ?? [];
      });
    } catch (e) {
      debugPrint('Error loading saved data: \$e');
    }
  }

  Future<void> _saveCurrentBackground(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('background_image_path', imagePath);
      setState(() {
        _currentBackground = imagePath;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('बैकग्राउंड सफलतापूर्वक सेट किया गया'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving background: \$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('बैकग्राउंड सेट करने में त्रुटि'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _saveCustomImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('custom_images', _customImages);
    } catch (e) {
      debugPrint('Error saving custom images: \$e');
    }
  }

  Future<void> _pickCustomImage() async {
    try {
      setState(() => _isLoading = true);
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _customImages.add(image.path);
        });
        await _saveCustomImages();
        
        HapticFeedback.mediumImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('कस्टम इमेज जोड़ी गई'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: \$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('इमेज चुनने में त्रुटि'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterBackgrounds(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (query.isEmpty) {
        _filteredBackgrounds = _spiritualBackgrounds.map((bg) => bg["url"] as String).toList();
      } else {
        _filteredBackgrounds = _spiritualBackgrounds
            .where((bg) => (bg["tags"] as List).any((tag) => 
                tag.toString().toLowerCase().contains(query.toLowerCase())))
            .map((bg) => bg["url"] as String)
            .toList();
      }
    });
  }

  void _showContextMenu(String imageUrl, bool isCustomImage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackgroundContextMenu(
        imageUrl: imageUrl,
        isCustomImage: isCustomImage,
        onPreview: () => _showPreviewDialog(imageUrl),
        onSetBackground: () => _saveCurrentBackground(imageUrl),
        onRemove: isCustomImage ? () => _removeCustomImage(imageUrl) : null,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showPreviewDialog(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => BackgroundPreviewDialog(
        imageUrl: imageUrl,
        onSetBackground: () => _saveCurrentBackground(imageUrl),
      ),
    );
  }

  void _removeCustomImage(String imagePath) {
    setState(() {
      _customImages.remove(imagePath);
    });
    _saveCustomImages();
    
    if (_currentBackground == imagePath) {
      _saveCurrentBackground('');
    }
    
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('कस्टम इमेज हटाई गई'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _refreshBackgrounds() async {
    setState(() => _isLoading = true);
    
    // Simulate loading additional backgrounds
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() => _isLoading = false);
    
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('बैकग्राउंड अपडेट किए गए'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final crossAxisCount = isTablet ? 3 : 2;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'बैकग्राउंड चुनें',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios_new',
            color: colorScheme.onSurface,
            size: 24,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
        ),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: RefreshIndicator(
                  onRefresh: _refreshBackgrounds,
                  color: colorScheme.primary,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Search bar
                      SliverToBoxAdapter(
                        child: SearchBarWidget(
                          controller: _searchController,
                          onChanged: _filterBackgrounds,
                          onClear: () => _filterBackgrounds(''),
                        ),
                      ),
                      
                      // Custom image card
                      SliverToBoxAdapter(
                        child: Container(
                          height: 25.h,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: CustomImageCard(
                            onTap: _pickCustomImage,
                          ),
                        ),
                      ),
                      
                      // Custom images section
                      if (_customImages.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              'आपकी इमेजेस',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final imageUrl = _customImages[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                child: BackgroundGridItem(
                                  imageUrl: imageUrl,
                                  isSelected: _currentBackground == imageUrl,
                                  isCustomImage: true,
                                  onTap: () => _saveCurrentBackground(imageUrl),
                                  onLongPress: () => _showContextMenu(imageUrl, true),
                                ),
                              );
                            },
                            childCount: _customImages.length,
                          ),
                        ),
                      ],
                      
                      // Spiritual backgrounds section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            _searchQuery.isEmpty ? 'आध्यात्मिक बैकग्राउंड' : 'खोज परिणाम',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      // Spiritual backgrounds grid
                      _filteredBackgrounds.isEmpty
                          ? SliverToBoxAdapter(
                              child: Container(
                                height: 30.h,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'search_off',
                                        color: colorScheme.onSurfaceVariant,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'कोई बैकग्राउंड नहीं मिला',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.8,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final imageUrl = _filteredBackgrounds[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 6),
                                    child: BackgroundGridItem(
                                      imageUrl: imageUrl,
                                      isSelected: _currentBackground == imageUrl,
                                      onTap: () => _saveCurrentBackground(imageUrl),
                                      onLongPress: () => _showContextMenu(imageUrl, false),
                                    ),
                                  );
                                },
                                childCount: _filteredBackgrounds.length,
                              ),
                            ),
                      
                      // Bottom spacing
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 20),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'लोड हो रहा है...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}