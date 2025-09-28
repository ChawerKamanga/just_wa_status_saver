import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/post.dart';

class VideoPostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const VideoPostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video thumbnail with controls
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusLarge),
                topRight: Radius.circular(AppDimensions.radiusLarge),
              ),
              child: AspectRatio(
                aspectRatio: post.aspectRatio,
                child: Stack(
                  children: [
                    // Video thumbnail/placeholder
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.textPrimary.withOpacity(0.8),
                            AppColors.textPrimary.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: post.imageUrl != null
                          ? Image.network(
                              post.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.textPrimary.withOpacity(0.3),
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_circle_filled,
                                      size: 64,
                                      color: AppColors.surface,
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Icon(
                                Icons.play_circle_filled,
                                size: 64,
                                color: AppColors.surface,
                              ),
                            ),
                    ),

                    // Duration overlay (top-left)
                    Positioned(
                      top: AppDimensions.spacing8,
                      left: AppDimensions.spacing8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing8,
                          vertical: AppDimensions.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSmall,
                          ),
                        ),
                        child: Text(
                          '2:34',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // Fullscreen button (top-right)
                    Positioned(
                      top: AppDimensions.spacing8,
                      right: AppDimensions.spacing8,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.spacing4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSmall,
                          ),
                        ),
                        child: const Icon(
                          Icons.fullscreen,
                          color: AppColors.surface,
                          size: AppDimensions.iconSmall,
                        ),
                      ),
                    ),

                    // Play button (center)
                    const Center(
                      child: Icon(
                        Icons.play_arrow,
                        size: 48,
                        color: AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (post.description != null) ...[
                    const SizedBox(height: AppDimensions.spacing8),
                    Text(
                      post.description!,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: AppDimensions.spacing12),

                  // Video stats
                  Row(
                    children: [
                      Icon(
                        Icons.play_arrow,
                        size: AppDimensions.iconSmall,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppDimensions.spacing4),
                      Text(
                        '${post.likes}K views',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(width: AppDimensions.spacing12),
                      Icon(
                        Icons.thumb_up_outlined,
                        size: AppDimensions.iconSmall,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppDimensions.spacing4),
                      Text('${post.likes}', style: AppTextStyles.bodySmall),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacing12),

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
                                style: AppTextStyles.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacing8),
                            Text('•', style: AppTextStyles.bodySmall),
                            const SizedBox(width: AppDimensions.spacing8),
                            Text(post.timeAgo, style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            child: Icon(
                              post.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: AppDimensions.iconSmall,
                              color: post.isLiked
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacing8),
                          GestureDetector(
                            child: Icon(
                              post.isSaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              size: AppDimensions.iconSmall,
                              color: post.isSaved
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacing4),
                          const Icon(
                            Icons.more_vert,
                            size: AppDimensions.iconSmall,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
