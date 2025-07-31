import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/achievements_timeline_widget.dart';
import './widgets/calendar_heatmap_widget.dart';
import './widgets/progress_indicators_widget.dart';
import './widgets/statistics_cards_widget.dart';
import './widgets/streak_header_widget.dart';

class ProgressAnalyticsScreen extends StatefulWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  State<ProgressAnalyticsScreen> createState() =>
      _ProgressAnalyticsScreenState();
}

class _ProgressAnalyticsScreenState extends State<ProgressAnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  // Mock data for demonstration
  int _currentStreak = 15;
  String _motivationalMessage = "आपकी निरंतर साधना प्रशंसनीय है! 🙏";

  // Progress data
  double _dailyProgress = 0.75; // 75% of daily goal
  double _weeklyProgress = 0.60; // 60% of weekly goal
  double _monthlyProgress = 0.45; // 45% of monthly goal

  int _dailyMalas = 3;
  int _weeklyMalas = 18;
  int _monthlyMalas = 67;

  // Statistics
  int _totalLifetimeMalas = 1247;
  int _longestStreak = 28;
  int _personalRanking = 42;

  // Practice data for heatmap
  Map<DateTime, int> _practiceData = {};

  // Achievements
  List<Map<String, dynamic>> _achievements = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProgressData();
    _generateMockData();
  }

  void _initializeAnimations() {
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _refreshAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.easeInOut,
    ));
  }

  void _loadProgressData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _currentStreak = prefs.getInt('current_streak') ?? 15;
        _dailyMalas = prefs.getInt('daily_malas') ?? 3;
        _weeklyMalas = prefs.getInt('weekly_malas') ?? 18;
        _monthlyMalas = prefs.getInt('monthly_malas') ?? 67;
        _totalLifetimeMalas = prefs.getInt('total_lifetime_malas') ?? 1247;
        _longestStreak = prefs.getInt('longest_streak') ?? 28;
        _personalRanking = prefs.getInt('personal_ranking') ?? 42;

        // Calculate progress percentages
        _dailyProgress = (_dailyMalas / 4.0).clamp(0.0, 1.0);
        _weeklyProgress = (_weeklyMalas / 30.0).clamp(0.0, 1.0);
        _monthlyProgress = (_monthlyMalas / 150.0).clamp(0.0, 1.0);
      });
    } catch (e) {
      // Handle error silently
    }
  }

  void _generateMockData() {
    // Generate practice data for the last 90 days
    final now = DateTime.now();
    for (int i = 0; i < 90; i++) {
      final date = now.subtract(Duration(days: i));
      final malaCount = (i % 7 == 0 || i % 7 == 6)
          ? (i % 3 == 0 ? 0 : (i % 5 + 1))
          : // Weekend variation
          (i % 4 + 1); // Weekday variation
      _practiceData[DateTime(date.year, date.month, date.day)] = malaCount;
    }

    // Generate achievements
    _achievements = [
      {
        'id': 1,
        'type': 'streak',
        'title': '15 दिन की निरंतर साधना',
        'description':
            'आपने लगातार 15 दिन तक जप किया है। यह एक महान उपलब्धि है!',
        'date': DateTime.now().subtract(const Duration(hours: 2)),
        'milestone': null,
      },
      {
        'id': 2,
        'type': 'milestone',
        'title': '1000 माला पूर्ण',
        'description':
            'आपने अपने आध्यात्मिक यात्रा में 1000 माला का मील का पत्थर पार किया है।',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'milestone': 1000,
      },
      {
        'id': 3,
        'type': 'weekly',
        'title': 'साप्ताहिक लक्ष्य प्राप्त',
        'description': 'इस सप्ताह आपने अपना लक्ष्य पूरा किया है। बधाई हो!',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'milestone': null,
      },
      {
        'id': 4,
        'type': 'daily',
        'title': 'दैनिक लक्ष्य 7 दिन',
        'description': 'आपने लगातार 7 दिन तक अपना दैनिक लक्ष्य पूरा किया है।',
        'date': DateTime.now().subtract(const Duration(days: 8)),
        'milestone': null,
      },
    ];
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();
    _refreshController.forward();

    // Simulate data refresh
    await Future.delayed(const Duration(milliseconds: 1500));

    _loadProgressData();
    _generateMockData();

    _refreshController.reverse();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('डेटा अपडेट हो गया'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _onDateTap(DateTime date, int malaCount) {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${date.day}/${date.month}/${date.year}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName:
                  malaCount > 0 ? 'self_improvement' : 'sentiment_neutral',
              color: malaCount > 0
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 12.w,
            ),
            SizedBox(height: 2.h),
            Text(
              malaCount > 0
                  ? '$malaCount माला पूर्ण की गई'
                  : 'इस दिन कोई जप नहीं किया गया',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (malaCount > 0) ...[
              SizedBox(height: 1.h),
              Text(
                'अनुमानित समय: ${malaCount * 15} मिनट',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('बंद करें'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _onDateLongPress(DateTime date, int malaCount) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'विशेष अवसर जोड़ें',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 2.h),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            TextField(
              decoration: const InputDecoration(
                labelText: 'टिप्पणी जोड़ें',
                hintText: 'इस दिन के लिए विशेष नोट...',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('रद्द करें'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('टिप्पणी सहेजी गई'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('सहेजें'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _onStatCardTap(String cardType) {
    HapticFeedback.lightImpact();
    // Additional functionality can be added here
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Sticky header with streak info
              SliverAppBar(
                expandedHeight: 20.h,
                floating: false,
                pinned: true,
                backgroundColor: colorScheme.surface,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: StreakHeaderWidget(
                      currentStreak: _currentStreak,
                      motivationalMessage: _motivationalMessage,
                    ),
                  ),
                ),
                title: Text(
                  'प्रगति विश्लेषण',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                actions: [
                  AnimatedBuilder(
                    animation: _refreshAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _refreshAnimation.value * 2 * 3.14159,
                        child: IconButton(
                          onPressed: _refreshData,
                          icon: CustomIconWidget(
                            iconName: 'refresh',
                            color: colorScheme.onSurface,
                            size: 6.w,
                          ),
                          tooltip: 'डेटा रीफ्रेश करें',
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Progress indicators
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
                    ProgressIndicatorsWidget(
                      dailyProgress: _dailyProgress,
                      weeklyProgress: _weeklyProgress,
                      monthlyProgress: _monthlyProgress,
                      dailyMalas: _dailyMalas,
                      weeklyMalas: _weeklyMalas,
                      monthlyMalas: _monthlyMalas,
                    ),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),

              // Calendar heatmap
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    CalendarHeatmapWidget(
                      practiceData: _practiceData,
                      onDateTap: _onDateTap,
                      onDateLongPress: _onDateLongPress,
                    ),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),

              // Statistics cards
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    StatisticsCardsWidget(
                      totalLifetimeMalas: _totalLifetimeMalas,
                      longestStreak: _longestStreak,
                      personalRanking: _personalRanking,
                      onCardTap: _onStatCardTap,
                    ),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),

              // Achievements timeline
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    AchievementsTimelineWidget(
                      achievements: _achievements,
                    ),
                    SizedBox(height: 10.h), // Extra space for bottom navigation
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/main-counter-screen');
              break;
            case 1:
              // Already on progress screen
              break;
            case 2:
              Navigator.pushNamed(context, '/settings-screen');
              break;
          }
        },
      ),
    );
  }
}