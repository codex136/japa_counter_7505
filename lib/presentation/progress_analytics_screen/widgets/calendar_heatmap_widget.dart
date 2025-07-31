import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CalendarHeatmapWidget extends StatefulWidget {
  final Map<DateTime, int> practiceData;
  final Function(DateTime, int)? onDateTap;
  final Function(DateTime, int)? onDateLongPress;

  const CalendarHeatmapWidget({
    super.key,
    required this.practiceData,
    this.onDateTap,
    this.onDateLongPress,
  });

  @override
  State<CalendarHeatmapWidget> createState() => _CalendarHeatmapWidgetState();
}

class _CalendarHeatmapWidgetState extends State<CalendarHeatmapWidget> {
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;

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
          _buildHeader(context),
          SizedBox(height: 2.h),
          _buildCalendarGrid(context),
          SizedBox(height: 2.h),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'अभ्यास कैलेंडर',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _currentMonth =
                      DateTime(_currentMonth.year, _currentMonth.month - 1);
                });
              },
              icon: CustomIconWidget(
                iconName: 'chevron_left',
                color: colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
            ),
            Text(
              _getMonthYearText(_currentMonth),
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _currentMonth =
                      DateTime(_currentMonth.year, _currentMonth.month + 1);
                });
              },
              icon: CustomIconWidget(
                iconName: 'chevron_right',
                color: colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        // Weekday headers
        Row(
          children: ['रवि', 'सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        SizedBox(height: 1.h),
        // Calendar grid
        ...List.generate(6, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex - startingWeekday + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return Expanded(child: SizedBox(height: 8.w));
              }

              final date =
                  DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
              final malaCount = widget.practiceData[date] ?? 0;
              final isSelected = _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedDate = date;
                    });
                    if (widget.onDateTap != null) {
                      widget.onDateTap!(date, malaCount);
                    }
                  },
                  onLongPress: () {
                    HapticFeedback.mediumImpact();
                    if (widget.onDateLongPress != null) {
                      widget.onDateLongPress!(date, malaCount);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.all(0.5.w),
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: _getHeatmapColor(malaCount, colorScheme),
                      borderRadius: BorderRadius.circular(4),
                      border: isSelected
                          ? Border.all(color: colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNumber',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: malaCount > 0
                              ? Colors.white
                              : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }).where((row) {
          // Only show rows that have at least one valid day
          return true;
        }).take(6),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'कम',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 0.5.w),
              width: 4.w,
              height: 4.w,
              decoration: BoxDecoration(
                color: _getHeatmapColor(index, colorScheme),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        Text(
          'अधिक',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getHeatmapColor(int malaCount, ColorScheme colorScheme) {
    if (malaCount == 0) {
      return colorScheme.surfaceContainerHighest;
    } else if (malaCount == 1) {
      return colorScheme.primary.withValues(alpha: 0.3);
    } else if (malaCount <= 3) {
      return colorScheme.primary.withValues(alpha: 0.5);
    } else if (malaCount <= 5) {
      return colorScheme.primary.withValues(alpha: 0.7);
    } else {
      return colorScheme.primary;
    }
  }

  String _getMonthYearText(DateTime date) {
    const months = [
      'जनवरी',
      'फरवरी',
      'मार्च',
      'अप्रैल',
      'मई',
      'जून',
      'जुलाई',
      'अगस्त',
      'सितंबर',
      'अक्टूबर',
      'नवंबर',
      'दिसंबर'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
