import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart'; // Corrected and completed import
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/post.dart';

class TextPostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const TextPostCard({super.key, required this.post, this.onTap});

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    if (hexCode.length == 6) {
      return Color(int.parse('FF$hexCode', radix: 16));
    }
    return Color(int.parse(hexCode, radix: 16));
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (post.backgroundColor != null) {
      return _colorFromHex(post.backgroundColor!);
    }

    // Default gradient colors
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      const Color(0xFF8B5A2B), // Brown
      const Color(0xFF059669), // Green
      const Color(0xFFDC2626), // Red
    ];

    return colors[post.id.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = _getBackgroundColor(theme); // Call with the theme

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 160),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor.withOpacity(0.8),
              backgroundColor.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: AppDimensions.cardBlurRadius,
              spreadRadius: AppDimensions.cardSpreadRadius,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                post.title,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),

              if (post.description != null) ...[
                const SizedBox(height: AppDimensions.spacing12),
                Text(
                  post.description!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.surface.withOpacity(0.9),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: AppDimensions.spacing24),

              // Actions row
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            post.author,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.surface.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacing8),
                        Text(
                          '•',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.surface.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacing8),
                        Text(
                          post.timeAgo,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.surface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          /* Handle like */
                        },
                        child: Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                          size: AppDimensions.iconSmall,
                          color: post.isLiked
                              ? AppColors.surface
                              : AppColors.surface.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing8),
                      GestureDetector(
                        onTap: () {
                          /* Handle save */
                        },
                        child: Icon(
                          post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                          size: AppDimensions.iconSmall,
                          color: post.isSaved
                              ? AppColors.surface
                              : AppColors.surface.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing4),
                      GestureDetector(
                        onTap: () {
                          /* Handle more options */
                        },
                        child: Icon(
                          Icons.more_vert,
                          size: AppDimensions.iconSmall,
                          color: AppColors.surface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
