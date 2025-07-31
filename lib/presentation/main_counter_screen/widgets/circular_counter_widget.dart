import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';


class CircularCounterWidget extends StatefulWidget {
  final int currentCount;
  final VoidCallback onTap;
  final bool isHapticsEnabled;

  const CircularCounterWidget({
    super.key,
    required this.currentCount,
    required this.onTap,
    required this.isHapticsEnabled,
  });

  @override
  State<CircularCounterWidget> createState() => _CircularCounterWidgetState();
}

class _CircularCounterWidgetState extends State<CircularCounterWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _celebrationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _celebrationAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(CircularCounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentCount != oldWidget.currentCount) {
      _triggerPulseAnimation();

      if (widget.currentCount == 0 && oldWidget.currentCount == 108) {
        _triggerCelebrationAnimation();
      }
    }
  }

  void _triggerPulseAnimation() {
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
  }

  void _triggerCelebrationAnimation() {
    _celebrationController.forward().then((_) {
      _celebrationController.reverse();
    });
  }

  void _handleTap() {
    if (widget.isHapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    widget.onTap();
  }

  String _getHindiNumeral(int number) {
    const hindiNumerals = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
    return number.toString().split('').map((digit) {
      int digitInt = int.parse(digit);
      return hindiNumerals[digitInt];
    }).join('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = widget.currentCount / 108.0;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _celebrationAnimation,
          _glowAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value * _celebrationAnimation.value,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary
                        .withValues(alpha: 0.3 * _glowAnimation.value),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 10 * _glowAnimation.value,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.surface.withValues(alpha: 0.9),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),

                  // Progress ring
                  SizedBox(
                    width: 80.w,
                    height: 80.w,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor:
                          colorScheme.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),

                  // Counter text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          _getHindiNumeral(widget.currentCount),
                          key: ValueKey(widget.currentCount),
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'जप',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),

                  // Celebration overlay
                  if (_glowAnimation.value > 0)
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            colorScheme.tertiary
                                .withValues(alpha: 0.3 * _glowAnimation.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }
}
