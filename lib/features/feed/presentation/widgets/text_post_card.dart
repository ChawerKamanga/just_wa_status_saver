import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/post.dart';

class TextPostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const TextPostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 160),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getBackgroundColor().withOpacity(0.8),
              _getBackgroundColor().withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
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
                        child: Icon(
                          post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                          size: AppDimensions.iconSmall,
                          color: post.isSaved
                              ? AppColors.surface
                              : AppColors.surface.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing4),
                      Icon(
                        Icons.more_vert,
                        size: AppDimensions.iconSmall,
                        color: AppColors.surface.withOpacity(0.8),
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

  Color _getBackgroundColor() {
    if (post.backgroundColor != null) {
      return Color(int.parse(post.backgroundColor!.replaceFirst('#', '0xFF')));
    }

    // Default gradient colors
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      const Color(0xFF8B5A2B), // Brown
      const Color(0xFF059669), // Green
      const Color(0xFFDC2626), // Red
    ];

    return colors[post.id.hashCode % colors.length];
  }
}
