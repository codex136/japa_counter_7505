import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/main_counter_screen/main_counter_screen.dart';
import '../presentation/progress_analytics_screen/progress_analytics_screen.dart';
import '../presentation/background_selection_screen/background_selection_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String settings = '/settings-screen';
  static const String mainCounter = '/main-counter-screen';
  static const String progressAnalytics = '/progress-analytics-screen';
  static const String backgroundSelection = '/background-selection-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    settings: (context) => const SettingsScreen(),
    mainCounter: (context) => const MainCounterScreen(),
    progressAnalytics: (context) => const ProgressAnalyticsScreen(),
    backgroundSelection: (context) => const BackgroundSelectionScreen(),
    // TODO: Add your other routes here
  };
}
