import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

class BackgroundOverlayWidget extends StatelessWidget {
  final String? backgroundImagePath;
  final Widget child;

  const BackgroundOverlayWidget({
    super.key,
    this.backgroundImagePath,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background image
          if (backgroundImagePath != null && backgroundImagePath!.isNotEmpty)
            Positioned.fill(
              child: CustomImageWidget(
                imageUrl: backgroundImagePath!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          // Overlay for text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.2),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Content
          child,
        ],
      ),
    );
  }
}
