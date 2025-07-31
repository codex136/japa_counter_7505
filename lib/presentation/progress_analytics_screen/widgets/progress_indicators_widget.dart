import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ProgressIndicatorsWidget extends StatefulWidget {
  final double dailyProgress;
  final double weeklyProgress;
  final double monthlyProgress;
  final int dailyMalas;
  final int weeklyMalas;
  final int monthlyMalas;

  const ProgressIndicatorsWidget({
    super.key,
    required this.dailyProgress,
    required this.weeklyProgress,
    required this.monthlyProgress,
    required this.dailyMalas,
    required this.weeklyMalas,
    required this.monthlyMalas,
  });

  @override
  State<ProgressIndicatorsWidget> createState() =>
      _ProgressIndicatorsWidgetState();
}

class _ProgressIndicatorsWidgetState extends State<ProgressIndicatorsWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _dailyAnimation;
  late Animation<double> _weeklyAnimation;
  late Animation<double> _monthlyAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _dailyAnimation = Tween<double>(
      begin: 0.0,
      end: widget.dailyProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));

    _weeklyAnimation = Tween<double>(
      begin: 0.0,
      end: widget.weeklyProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
    ));

    _monthlyAnimation = Tween<double>(
      begin: 0.0,
      end: widget.monthlyProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildProgressIndicator(
            context: context,
            animation: _dailyAnimation,
            title: 'आज',
            subtitle: 'दैनिक',
            count: widget.dailyMalas,
            color: colorScheme.primary,
          ),
          _buildProgressIndicator(
            context: context,
            animation: _weeklyAnimation,
            title: 'सप्ताह',
            subtitle: 'साप्ताहिक',
            count: widget.weeklyMalas,
            color: colorScheme.tertiary,
          ),
          _buildProgressIndicator(
            context: context,
            animation: _monthlyAnimation,
            title: 'महीना',
            subtitle: 'मासिक',
            count: widget.monthlyMalas,
            color: colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator({
    required BuildContext context,
    required Animation<double> animation,
    required String title,
    required String subtitle,
    required int count,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return SizedBox(
                width: 20.w,
                height: 20.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: animation.value,
                      strokeWidth: 6,
                      backgroundColor: color.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$count',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'माला',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
