import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';

class BackgroundContextMenu extends StatelessWidget {
  final String imageUrl;
  final bool isCustomImage;
  final VoidCallback onPreview;
  final VoidCallback onSetBackground;
  final VoidCallback? onRemove;
  final VoidCallback onClose;

  const BackgroundContextMenu({
    super.key,
    required this.imageUrl,
    required this.isCustomImage,
    required this.onPreview,
    required this.onSetBackground,
    this.onRemove,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 120,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomImageWidget(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(
              context: context,
              icon: 'visibility',
              title: 'प्रीव्यू',
              onTap: () {
                HapticFeedback.lightImpact();
                onClose();
                onPreview();
              },
            ),
            _buildMenuItem(
              context: context,
              icon: 'wallpaper',
              title: 'बैकग्राउंड सेट करें',
              onTap: () {
                HapticFeedback.lightImpact();
                onClose();
                onSetBackground();
              },
            ),
            if (isCustomImage && onRemove != null)
              _buildMenuItem(
                context: context,
                icon: 'delete',
                title: 'हटाएं',
                isDestructive: true,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onClose();
                  onRemove!();
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isDestructive ? colorScheme.error : colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color:
                    isDestructive ? colorScheme.error : colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
