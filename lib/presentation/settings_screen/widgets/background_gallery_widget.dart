import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BackgroundGalleryWidget extends StatefulWidget {
  final Function(String) onBackgroundSelected;

  const BackgroundGalleryWidget({
    super.key,
    required this.onBackgroundSelected,
  });

  @override
  State<BackgroundGalleryWidget> createState() =>
      _BackgroundGalleryWidgetState();
}

class _BackgroundGalleryWidgetState extends State<BackgroundGalleryWidget> {
  String _selectedBackground = '';

  final List<Map<String, dynamic>> _predefinedBackgrounds = [
    {
      "id": "temple1",
      "name": "गोल्डन टेम्पल",
      "imageUrl":
          "https://images.pexels.com/photos/3408354/pexels-photo-3408354.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
    {
      "id": "meditation1",
      "name": "ध्यान स्थल",
      "imageUrl":
          "https://images.pixabay.com/photo-2017/08/06/12/06/people-2591874_1280.jpg",
    },
    {
      "id": "lotus1",
      "name": "कमल फूल",
      "imageUrl":
          "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80",
    },
    {
      "id": "ganges1",
      "name": "गंगा आरती",
      "imageUrl":
          "https://images.pexels.com/photos/8078361/pexels-photo-8078361.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
    {
      "id": "mountain1",
      "name": "हिमालय",
      "imageUrl":
          "https://images.pixabay.com/photo-2018/01/14/23/12/nature-3082832_1280.jpg",
    },
    {
      "id": "sunrise1",
      "name": "सूर्योदय",
      "imageUrl":
          "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedBackground();
  }

  Future<void> _loadSelectedBackground() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedBackground = prefs.getString('selected_background') ??
          _predefinedBackgrounds[0]['id'];
    });
  }

  Future<void> _selectBackground(String backgroundId, String imageUrl) async {
    HapticFeedback.lightImpact();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_background', backgroundId);
    await prefs.setString('background_image_url', imageUrl);

    setState(() {
      _selectedBackground = backgroundId;
    });

    widget.onBackgroundSelected(imageUrl);

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('बैकग्राउंड बदल दिया गया'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showBackgroundPreview(String imageUrl, String name) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 90.w,
            height: 70.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  CustomImageWidget(
                    imageUrl: imageUrl,
                    width: 90.w,
                    height: 70.h,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 25.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Text(
              'पूर्व-निर्धारित बैकग्राउंड',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _predefinedBackgrounds.length,
              itemBuilder: (context, index) {
                final background = _predefinedBackgrounds[index];
                final isSelected = _selectedBackground == background['id'];

                return GestureDetector(
                  onTap: () => _selectBackground(
                      background['id'], background['imageUrl']),
                  onLongPress: () => _showBackgroundPreview(
                      background['imageUrl'], background['name']),
                  child: Container(
                    width: 30.w,
                    margin: EdgeInsets.only(right: 3.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 3,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.colorScheme.shadow.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          CustomImageWidget(
                            imageUrl: background['imageUrl'],
                            width: 30.w,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          if (isSelected)
                            Positioned(
                              top: 1.w,
                              right: 1.w,
                              child: Container(
                                padding: EdgeInsets.all(1.w),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: CustomIconWidget(
                                  iconName: 'check',
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.7),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Text(
                                background['name'],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
