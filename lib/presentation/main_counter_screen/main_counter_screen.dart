import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/background_overlay_widget.dart';
import './widgets/circular_counter_widget.dart';
import './widgets/mala_progress_widget.dart';

class MainCounterScreen extends StatefulWidget {
  const MainCounterScreen({super.key});

  @override
  State<MainCounterScreen> createState() => _MainCounterScreenState();
}

class _MainCounterScreenState extends State<MainCounterScreen>
    with TickerProviderStateMixin {
  int _currentCount = 0;
  int _todayMalaCount = 0;
  bool _isHapticsEnabled = true;
  String? _backgroundImagePath;

  late AnimationController _celebrationController;
  late Animation<double> _celebrationScale;
  late Animation<Color?> _celebrationColor;

  // Mock spiritual background images
  final List<String> _defaultBackgrounds = [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?fm=jpg&q=60&w=3000',
    'https://images.unsplash.com/photo-1518709268805-4e9042af2176?fm=jpg&q=60&w=3000',
    'https://images.unsplash.com/photo-1544735716-392fe2489ffa?fm=jpg&q=60&w=3000',
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?fm=jpg&q=60&w=3000',
    'https://images.pexels.com/photos/1051838/pexels-photo-1051838.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _celebrationScale = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    _celebrationColor = ColorTween(
      begin: Colors.transparent,
      end: AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.3),
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentCount = prefs.getInt('current_count') ?? 0;
      _todayMalaCount = prefs.getInt('today_mala_count') ?? 0;
      _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
      _backgroundImagePath =
          prefs.getString('background_image_path') ?? _defaultBackgrounds[0];

      // Check if it's a new day
      final lastDate = prefs.getString('last_date') ?? '';
      final today = DateTime.now().toIso8601String().split('T')[0];
      if (lastDate != today) {
        _todayMalaCount = 0;
        prefs.setString('last_date', today);
        prefs.setInt('today_mala_count', 0);
      }
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_count', _currentCount);
    await prefs.setInt('today_mala_count', _todayMalaCount);
    await prefs.setBool('haptics_enabled', _isHapticsEnabled);
    if (_backgroundImagePath != null) {
      await prefs.setString('background_image_path', _backgroundImagePath!);
    }

    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('last_date', today);
  }

  void _incrementCounter() {
    setState(() {
      if (_currentCount < 108) {
        _currentCount++;
      }

      if (_currentCount == 108) {
        _triggerMalaCompletion();
      }
    });
    _savePreferences();
  }

  void _triggerMalaCompletion() {
    // Celebration animation
    _celebrationController.forward().then((_) {
      _celebrationController.reverse();
    });

    // Haptic feedback for completion
    if (_isHapticsEnabled) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.mediumImpact();
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        HapticFeedback.lightImpact();
      });
    }

    // Auto-reset and increment daily count
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _currentCount = 0;
        _todayMalaCount++;
      });
      _savePreferences();
    });
  }

  void _resetCurrentCount() {
    setState(() {
      _currentCount = 0;
    });
    _savePreferences();
  }

  void _changeBackground() {
    Navigator.pushNamed(context, '/background-selection-screen');
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings-screen');
  }

  void _navigateToProgress() {
    Navigator.pushNamed(context, '/progress-analytics-screen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _changeBackground,
          icon: CustomIconWidget(
            iconName: 'image',
            color: colorScheme.onSurface,
            size: 24,
          ),
          tooltip: 'पृष्ठभूमि बदलें',
        ),
        title: Text(
          'जप काउंटर',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _navigateToSettings,
            icon: CustomIconWidget(
              iconName: 'settings',
              color: colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'सेटिंग्स',
          ),
        ],
      ),
      body: BackgroundOverlayWidget(
        backgroundImagePath: _backgroundImagePath,
        child: SafeArea(
          child: GestureDetector(
            onTap: _incrementCounter,
            behavior: HitTestBehavior.translucent,
            child: AnimatedBuilder(
              animation: _celebrationController,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: _celebrationColor.value,
                  ),
                  child: Transform.scale(
                    scale: _celebrationScale.value,
                    child: Column(
                      children: [
                        // Top spacing
                        SizedBox(height: 4.h),

                        // Today's mala progress
                        MalaProgressWidget(
                          todayMalaCount: _todayMalaCount,
                        ),

                        // Main counter area
                        Expanded(
                          child: Center(
                            child: CircularCounterWidget(
                              currentCount: _currentCount,
                              onTap: _incrementCounter,
                              isHapticsEnabled: _isHapticsEnabled,
                            ),
                          ),
                        ),

                        // Action buttons
                        ActionButtonsWidget(
                          onReset: _resetCurrentCount,
                          onBackgroundChange: _changeBackground,
                          isHapticsEnabled: _isHapticsEnabled,
                        ),

                        // Bottom spacing
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on counter screen
              break;
            case 1:
              _navigateToProgress();
              break;
            case 2:
              _navigateToSettings();
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'self_improvement',
              color: colorScheme.primary,
              size: 24,
            ),
            label: 'काउंटर',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'analytics',
              color: colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'प्रगति',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'settings',
              color: colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'सेटिंग्स',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }
}
