import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AchievementsTimelineWidget extends StatelessWidget {
  final List<Map<String, dynamic>> achievements;

  const AchievementsTimelineWidget({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'हाल की उपलब्धियां',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ...achievements.asMap().entries.map((entry) {
            final index = entry.key;
            final achievement = entry.value;
            final isLast = index == achievements.length - 1;

            return _buildTimelineItem(
              context: context,
              achievement: achievement,
              isLast: isLast,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required BuildContext context,
    required Map<String, dynamic> achievement,
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: _getAchievementColor(
                      achievement['type'] as String, colorScheme),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getAchievementColor(
                              achievement['type'] as String, colorScheme)
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName:
                        _getAchievementIcon(achievement['type'] as String),
                    color: Colors.white,
                    size: 5.w,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 8.h,
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
            ],
          ),
          SizedBox(width: 4.w),
          // Achievement content
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showAchievementDetails(context, achievement);
              },
              child: Container(
                padding: EdgeInsets.all(3.w),
                margin: EdgeInsets.only(bottom: isLast ? 0 : 2.h),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            achievement['title'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(achievement['date'] as DateTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      achievement['description'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (achievement['milestone'] != null) ...[
                      SizedBox(height: 1.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getAchievementColor(
                                  achievement['type'] as String, colorScheme)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${achievement['milestone']} माला पूर्ण',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getAchievementColor(
                                achievement['type'] as String, colorScheme),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAchievementColor(String type, ColorScheme colorScheme) {
    switch (type) {
      case 'streak':
        return colorScheme.primary;
      case 'milestone':
        return colorScheme.tertiary;
      case 'daily':
        return colorScheme.secondary;
      case 'weekly':
        return Colors.green;
      case 'monthly':
        return Colors.purple;
      default:
        return colorScheme.primary;
    }
  }

  String _getAchievementIcon(String type) {
    switch (type) {
      case 'streak':
        return 'local_fire_department';
      case 'milestone':
        return 'emoji_events';
      case 'daily':
        return 'today';
      case 'weekly':
        return 'date_range';
      case 'monthly':
        return 'calendar_month';
      default:
        return 'star';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'आज';
    } else if (difference == 1) {
      return 'कल';
    } else if (difference < 7) {
      return '$difference दिन पहले';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks सप्ताह पहले';
    } else {
      final months = (difference / 30).floor();
      return '$months महीने पहले';
    }
  }

  void _showAchievementDetails(
      BuildContext context, Map<String, dynamic> achievement) {
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
              achievement['title'] as String,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              achievement['description'] as String,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (achievement['milestone'] != null) ...[
              SizedBox(height: 2.h),
              Text(
                '${achievement['milestone']} माला की उपलब्धि',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('बंद करें'),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
