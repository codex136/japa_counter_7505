import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/background_gallery_widget.dart';
import './widgets/reset_confirmation_dialog.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool _isHapticsEnabled = true;
  bool _isHindiLanguage = true;
  String _selectedBackground = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();
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

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
      _isHindiLanguage = prefs.getBool('hindi_language') ?? true;
      _selectedBackground = prefs.getString('selected_background') ?? 'temple1';
    });
  }

  Future<void> _toggleHaptics(bool value) async {
    if (value) {
      HapticFeedback.lightImpact();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptics_enabled', value);

    setState(() {
      _isHapticsEnabled = value;
    });

    _showSuccessToast('हैप्टिक फीडबैक ${value ? 'चालू' : 'बंद'} कर दिया गया');
  }

  Future<void> _toggleLanguage(bool value) async {
    if (_isHapticsEnabled) {
      HapticFeedback.lightImpact();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hindi_language', value);

    setState(() {
      _isHindiLanguage = value;
    });

    _showSuccessToast('भाषा ${value ? 'हिंदी' : 'English'} में बदल दी गई');
  }

  Future<void> _selectCustomImage() async {
    if (_isHapticsEnabled) {
      HapticFeedback.lightImpact();
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('custom_background_path', image.path);
        await prefs.setString('selected_background', 'custom');

        setState(() {
          _selectedBackground = 'custom';
        });

        _showSuccessToast('कस्टम बैकग्राउंड सेट कर दिया गया');
      }
    } catch (e) {
      _showErrorToast('इमेज सेलेक्ट करने में समस्या हुई');
    }
  }

  void _openBackgroundSelection() {
    if (_isHapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    Navigator.pushNamed(context, '/background-selection-screen');
  }

  Future<void> _resetTodayCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('today_mala_count', 0);
    await prefs.setInt('current_count', 0);

    if (_isHapticsEnabled) {
      HapticFeedback.mediumImpact();
    }

    _showSuccessToast('आज की गिनती रीसेट कर दी गई');
  }

  Future<void> _resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // Reset all counters and progress to zero
    await prefs.setInt('current_count', 0);
    await prefs.setInt('today_mala_count', 0);
    await prefs.setInt('total_mala_count', 0);
    await prefs.setInt('total_lifetime_malas', 0);

    // Reset all streak data
    await prefs.setInt('current_streak', 0);
    await prefs.setInt('best_streak', 0);
    await prefs.setInt('longest_streak', 0);

    // Reset daily, weekly, monthly progress
    await prefs.setInt('daily_malas', 0);
    await prefs.setInt('weekly_malas', 0);
    await prefs.setInt('monthly_malas', 0);

    // Reset ranking and statistics
    await prefs.setInt('personal_ranking', 0);

    // Clear all daily progress data and date-specific entries
    final keys = prefs
        .getKeys()
        .where((key) =>
            key.startsWith('daily_count_') ||
            key.startsWith('practice_date_') ||
            key.startsWith('achievement_') ||
            key.startsWith('milestone_'))
        .toList();

    for (String key in keys) {
      await prefs.remove(key);
    }

    // Reset last date to today to ensure fresh start
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('last_date', today);

    if (_isHapticsEnabled) {
      HapticFeedback.heavyImpact();
    }

    _showSuccessToast('सभी प्रगति रीसेट कर दी गई - नई शुरुआत के लिए तैयार!');
  }

  void _showResetTodayDialog() {
    showDialog(
      context: context,
      builder: (context) => ResetConfirmationDialog(
        title: 'आज की गिनती रीसेट करें?',
        message:
            'क्या आप वाकई आज की मालाओं की गिनती को रीसेट करना चाहते हैं? यह क्रिया पूर्ववत नहीं की जा सकती।',
        confirmText: 'रीसेट करें',
        onConfirm: _resetTodayCount,
      ),
    );
  }

  void _showResetAllDialog() {
    showDialog(
      context: context,
      builder: (context) => ResetConfirmationDialog(
        title: 'सभी प्रगति रीसेट करें?',
        message:
            'क्या आप वाकई अपनी सभी प्रगति, आंकड़े और उपलब्धियों को रीसेट करना चाहते हैं? यह क्रिया पूर्ववत नहीं की जा सकती।',
        confirmText: 'सभी रीसेट करें',
        onConfirm: _resetAllProgress,
      ),
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Colors.white,
      fontSize: 14.sp,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.error,
      textColor: Colors.white,
      fontSize: 14.sp,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'सेटिंग्स',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            if (_isHapticsEnabled) {
              HapticFeedback.lightImpact();
            }
            Navigator.pop(context);
          },
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios_new',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 2.h),

                // Haptic Feedback Section
                SettingsSectionWidget(
                  title: 'अनुभव सेटिंग्स',
                  children: [
                    SettingsItemWidget(
                      iconName: 'vibration',
                      title: 'हैप्टिक फीडबैक',
                      subtitle: 'स्पर्श पर कंपन सक्रिय करें',
                      trailing: Switch.adaptive(
                        value: _isHapticsEnabled,
                        onChanged: _toggleHaptics,
                        activeColor: theme.colorScheme.primary,
                      ),
                      isLast: true,
                    ),
                  ],
                ),

                // Background Customization Section
                SettingsSectionWidget(
                  title: 'बैकग्राउंड सेटिंग्स',
                  children: [
                    SettingsItemWidget(
                      iconName: 'image',
                      title: 'बैकग्राउंड गैलरी',
                      subtitle: 'पूर्व-निर्धारित बैकग्राउंड चुनें',
                      onTap: _openBackgroundSelection,
                    ),
                    SettingsItemWidget(
                      iconName: 'add_photo_alternate',
                      title: 'कस्टम इमेज',
                      subtitle: 'अपनी गैलरी से इमेज चुनें',
                      onTap: _selectCustomImage,
                      isLast: true,
                    ),
                  ],
                ),

                // Background Gallery Preview
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: BackgroundGalleryWidget(
                    onBackgroundSelected: (imageUrl) {
                      setState(() {
                        _selectedBackground = imageUrl;
                      });
                    },
                  ),
                ),

                // Language Section
                SettingsSectionWidget(
                  title: 'भाषा सेटिंग्स',
                  children: [
                    SettingsItemWidget(
                      iconName: 'language',
                      title: 'हिंदी भाषा',
                      subtitle: 'ऐप को हिंदी में दिखाएं',
                      trailing: Switch.adaptive(
                        value: _isHindiLanguage,
                        onChanged: _toggleLanguage,
                        activeColor: theme.colorScheme.primary,
                      ),
                      isLast: true,
                    ),
                  ],
                ),

                // Reset Section
                SettingsSectionWidget(
                  title: 'रीसेट विकल्प',
                  children: [
                    SettingsItemWidget(
                      iconName: 'refresh',
                      title: 'आज की गिनती रीसेट करें',
                      subtitle: 'केवल आज की मालाओं की गिनती साफ करें',
                      onTap: _showResetTodayDialog,
                    ),
                    SettingsItemWidget(
                      iconName: 'delete_forever',
                      title: 'सभी प्रगति रीसेट करें',
                      subtitle: 'सभी डेटा और आंकड़े साफ करें',
                      onTap: _showResetAllDialog,
                      isLast: true,
                    ),
                  ],
                ),

                // App Info Section
                SettingsSectionWidget(
                  title: 'ऐप जानकारी',
                  children: [
                    SettingsItemWidget(
                      iconName: 'info',
                      title: 'जपा काउंटर',
                      subtitle: 'संस्करण 1.0.0 • आध्यात्मिक साधना के लिए',
                      isLast: true,
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

                // Footer
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    'ॐ शांति शांति शांति:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
