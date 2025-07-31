import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _backgroundAnimation;

  bool _isInitialized = false;
  String? _backgroundImagePath;
  int _dailyMalaCount = 0;
  bool _isHapticsEnabled = true;
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Background animation controller
    _backgroundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    // Background gradient animation
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _backgroundAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _logoAnimationController.forward();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize SharedPreferences and load user data
      await _loadUserPreferences();

      // Initialize haptic feedback settings
      await _initializeHapticFeedback();

      // Load custom background images
      await _loadCustomBackgrounds();

      // Mark initialization as complete
      setState(() {
        _isInitialized = true;
      });

      // Navigate after splash duration
      await Future.delayed(const Duration(milliseconds: 2500));
      _navigateToNextScreen();
    } catch (e) {
      // Handle initialization errors gracefully
      await _resetToDefaults();
      setState(() {
        _isInitialized = true;
      });

      await Future.delayed(const Duration(milliseconds: 2500));
      _navigateToNextScreen();
    }
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load daily mala count
    _dailyMalaCount = prefs.getInt('daily_mala_count') ?? 0;

    // Load haptic feedback setting
    _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;

    // Load background image path
    _backgroundImagePath = prefs.getString('background_image_path');

    // Check if first time user
    _isFirstTime = prefs.getBool('is_first_time') ?? true;

    // If not first time, mark as returning user
    if (!_isFirstTime) {
      await prefs.setBool('is_first_time', false);
    }
  }

  Future<void> _initializeHapticFeedback() async {
    if (_isHapticsEnabled) {
      try {
        // Test haptic feedback availability
        await HapticFeedback.lightImpact();
      } catch (e) {
        // Disable haptics if not available
        _isHapticsEnabled = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('haptics_enabled', false);
      }
    }
  }

  Future<void> _loadCustomBackgrounds() async {
    if (_backgroundImagePath != null) {
      // Verify custom background image still exists
      try {
        // This would normally check if file exists
        // For now, we'll assume it's valid if path is stored
      } catch (e) {
        // Reset to default if custom image is missing
        _backgroundImagePath = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('background_image_path');
      }
    }
  }

  Future<void> _resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();

    // Reset to safe defaults
    _dailyMalaCount = 0;
    _isHapticsEnabled = true;
    _backgroundImagePath = null;
    _isFirstTime = true;

    // Clear potentially corrupted preferences
    await prefs.clear();

    // Set safe defaults
    await prefs.setInt('daily_mala_count', 0);
    await prefs.setBool('haptics_enabled', true);
    await prefs.setBool('is_first_time', true);
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    // Navigate to main counter screen
    // All users go to main counter as per requirements
    Navigator.pushReplacementNamed(context, '/main-counter-screen');
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryLight.withValues(
                    alpha: 0.8 + (0.2 * _backgroundAnimation.value),
                  ),
                  AppTheme.accentLight.withValues(
                    alpha: 0.6 + (0.4 * _backgroundAnimation.value),
                  ),
                  AppTheme.primaryVariantLight.withValues(
                    alpha: 0.9 + (0.1 * _backgroundAnimation.value),
                  ),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spacer to push content to center
                  const Spacer(flex: 2),

                  // App Logo with animations
                  _buildAnimatedLogo(),

                  SizedBox(height: 4.h),

                  // App title
                  _buildAppTitle(),

                  SizedBox(height: 2.h),

                  // Subtitle
                  _buildSubtitle(),

                  const Spacer(flex: 2),

                  // Loading indicator
                  _buildLoadingIndicator(),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoFadeAnimation,
          child: ScaleTransition(
            scale: _logoScaleAnimation,
            child: Container(
              width: 25.w,
              height: 25.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.lightTheme.colorScheme.surface,
                    AppTheme.accentLight.withValues(alpha: 0.3),
                    AppTheme.primaryLight.withValues(alpha: 0.1),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryLight.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'self_improvement',
                  size: 12.w,
                  color: AppTheme.primaryLight,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppTitle() {
    return AnimatedBuilder(
      animation: _logoFadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoFadeAnimation,
          child: Text(
            'जप काउंटर',
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.surface,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: AppTheme.primaryVariantLight.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return AnimatedBuilder(
      animation: _logoFadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoFadeAnimation,
          child: Text(
            'आध्यात्मिक साधना के लिए',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.9),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _logoFadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoFadeAnimation,
          child: Column(
            children: [
              SizedBox(
                width: 8.w,
                height: 8.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.surface,
                  ),
                  backgroundColor: AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.3),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _isInitialized ? 'तैयार हो रहा है...' : 'लोड हो रहा है...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
