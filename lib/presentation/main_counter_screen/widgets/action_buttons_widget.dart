import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onBackgroundChange;
  final bool isHapticsEnabled;

  const ActionButtonsWidget({
    super.key,
    required this.onReset,
    required this.onBackgroundChange,
    required this.isHapticsEnabled,
  });

  void _handleReset(BuildContext context) {
    if (isHapticsEnabled) {
      HapticFeedback.mediumImpact();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'रीसेट करें',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'क्या आप वर्तमान जप काउंट को रीसेट करना चाहते हैं?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'रद्द करें',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onReset();
              },
              child: Text('रीसेट करें'),
            ),
          ],
        );
      },
    );
  }

  void _handleBackgroundChange() {
    if (isHapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    onBackgroundChange();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Background change button
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: _handleBackgroundChange,
              icon: CustomIconWidget(
                iconName: 'image',
                color: colorScheme.primary,
                size: 24,
              ),
              tooltip: 'पृष्ठभूमि बदलें',
            ),
          ),

          // Reset button
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () => _handleReset(context),
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: colorScheme.error,
                size: 24,
              ),
              tooltip: 'रीसेट करें',
            ),
          ),
        ],
      ),
    );
  }
}
