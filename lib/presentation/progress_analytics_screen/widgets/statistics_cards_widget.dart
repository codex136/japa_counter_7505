import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class StatisticsCardsWidget extends StatelessWidget {
  final int totalLifetimeMalas;
  final int longestStreak;
  final int personalRanking;
  final Function(String)? onCardTap;

  const StatisticsCardsWidget({
    super.key,
    required this.totalLifetimeMalas,
    required this.longestStreak,
    required this.personalRanking,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context: context,
                  title: 'कुल माला',
                  value: '$totalLifetimeMalas',
                  subtitle: 'जीवनकाल',
                  icon: 'self_improvement',
                  color: Theme.of(context).colorScheme.primary,
                  cardType: 'lifetime',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  context: context,
                  title: 'सबसे लंबी',
                  value: '$longestStreak',
                  subtitle: 'दिन की श्रृंखला',
                  icon: 'local_fire_department',
                  color: Theme.of(context).colorScheme.tertiary,
                  cardType: 'streak',
                ),
              ),
            ],
          ),
          SizedBox(height: 3.w),
          _buildStatCard(
            context: context,
            title: 'व्यक्तिगत रैंकिंग',
            value: '#$personalRanking',
            subtitle: 'आध्यात्मिक यात्रा में स्थान',
            icon: 'emoji_events',
            color: Theme.of(context).colorScheme.secondary,
            cardType: 'ranking',
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required String icon,
    required Color color,
    required String cardType,
    bool isFullWidth = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onCardTap != null) {
          onCardTap!(cardType);
        }
        _showDetailedStats(context, cardType, title, value, subtitle);
      },
      child: Container(
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
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: isFullWidth
            ? Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: icon,
                      color: color,
                      size: 8.w,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          value,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'chevron_right',
                    color: colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: icon,
                          color: color,
                          size: 6.w,
                        ),
                      ),
                      CustomIconWidget(
                        iconName: 'chevron_right',
                        color: colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      ),
    );
  }

  void _showDetailedStats(BuildContext context, String cardType, String title,
      String value, String subtitle) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              value,
              style: theme.textTheme.displaySmall?.copyWith(
                color: _getCardColor(cardType, colorScheme),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ..._getDetailedInfo(cardType, theme, colorScheme),
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

  Color _getCardColor(String cardType, ColorScheme colorScheme) {
    switch (cardType) {
      case 'lifetime':
        return colorScheme.primary;
      case 'streak':
        return colorScheme.tertiary;
      case 'ranking':
        return colorScheme.secondary;
      default:
        return colorScheme.primary;
    }
  }

  List<Widget> _getDetailedInfo(
      String cardType, ThemeData theme, ColorScheme colorScheme) {
    switch (cardType) {
      case 'lifetime':
        return [
          _buildInfoRow(
              'औसत दैनिक माला:',
              '${(totalLifetimeMalas / 365).toStringAsFixed(1)}',
              theme,
              colorScheme),
          _buildInfoRow(
              'अनुमानित समय:',
              '${(totalLifetimeMalas * 15).toStringAsFixed(0)} मिनट',
              theme,
              colorScheme),
          _buildInfoRow(
              'आध्यात्मिक यात्रा:',
              '${(totalLifetimeMalas / 108).toStringAsFixed(0)} पूर्ण चक्र',
              theme,
              colorScheme),
        ];
      case 'streak':
        return [
          _buildInfoRow(
              'वर्तमान श्रृंखला:', '$longestStreak दिन', theme, colorScheme),
          _buildInfoRow(
              'निरंतरता दर:',
              '${((longestStreak / 30) * 100).toStringAsFixed(1)}%',
              theme,
              colorScheme),
          _buildInfoRow('अगला लक्ष्य:', '${((longestStreak ~/ 7 + 1) * 7)} दिन',
              theme, colorScheme),
        ];
      case 'ranking':
        return [
          _buildInfoRow('श्रेणी स्तर:', _getRankingLevel(personalRanking),
              theme, colorScheme),
          _buildInfoRow(
              'अगला स्तर:', _getNextLevel(personalRanking), theme, colorScheme),
          _buildInfoRow('प्रगति:', '${((personalRanking % 10) * 10)}%', theme,
              colorScheme),
        ];
      default:
        return [];
    }
  }

  Widget _buildInfoRow(
      String label, String value, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getRankingLevel(int ranking) {
    if (ranking <= 10) return 'गुरु स्तर';
    if (ranking <= 50) return 'उन्नत साधक';
    if (ranking <= 100) return 'मध्यम साधक';
    return 'नवीन साधक';
  }

  String _getNextLevel(int ranking) {
    if (ranking <= 10) return 'महागुरु';
    if (ranking <= 50) return 'गुरु स्तर';
    if (ranking <= 100) return 'उन्नत साधक';
    return 'मध्यम साधक';
  }
}
