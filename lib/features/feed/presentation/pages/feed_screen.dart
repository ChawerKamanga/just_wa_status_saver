import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/post.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/top_tab_bar.dart';
import '../viewmodels/feed_view_model.dart';
import '../widgets/banking_post_card.dart';
import '../widgets/image_post_card.dart';
import '../widgets/text_post_card.dart';
import '../widgets/video_post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedViewModel(),
      child: const _FeedScreenContent(),
    );
  }
}

class _FeedScreenContent extends StatelessWidget {
  const _FeedScreenContent();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedNavIndex: 0,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          AppStrings.appName,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: AppDimensions.spacing8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(AppDimensions.tabBarHeight),
          child: Consumer<FeedViewModel>(
            builder: (context, viewModel, _) {
              return TopTabBar(
                tabs: viewModel.tabs,
                selectedIndex: viewModel.selectedTabIndex,
                onTabSelected: viewModel.selectTab,
              );
            },
          ),
        ),
      ),
      body: Consumer<FeedViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Simulate refresh
              await Future.delayed(const Duration(seconds: 1));
              viewModel.selectTab(viewModel.selectedTabIndex);
            },
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppDimensions.gridSpacing,
                mainAxisSpacing: AppDimensions.gridSpacing,
                itemCount: viewModel.posts.length,
                itemBuilder: (context, index) {
                  final post = viewModel.posts[index];
                  return _buildPostCard(context, post, viewModel);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(
    BuildContext context,
    Post post,
    FeedViewModel viewModel,
  ) {
    switch (post.type) {
      case PostType.banking:
        return BankingPostCard(
          post: post,
          onTap: () => _onPostTap(context, post),
        );
      case PostType.image:
        return ImagePostCard(
          post: post,
          onTap: () => _onPostTap(context, post),
        );
      case PostType.video:
        return VideoPostCard(
          post: post,
          onTap: () => _onPostTap(context, post),
        );
      case PostType.text:
        return TextPostCard(post: post, onTap: () => _onPostTap(context, post));
    }
  }

  void _onPostTap(BuildContext context, Post post) {
    // Handle post tap - could navigate to detail screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PostDetailBottomSheet(post: post),
    );
  }
}

class _PostDetailBottomSheet extends StatelessWidget {
  final Post post;

  const _PostDetailBottomSheet({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusXL),
          topRight: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppDimensions.spacing12),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing20),
            child: Row(
              children: [
                Expanded(
                  child: Text(post.title, style: AppTextStyles.headlineSmall),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLarge,
                      ),
                      child: AspectRatio(
                        aspectRatio: post.aspectRatio,
                        child: Image.network(
                          post.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),

                  const SizedBox(height: AppDimensions.spacing20),

                  Text('By ${post.author}', style: AppTextStyles.bodySmall),

                  const SizedBox(height: AppDimensions.spacing8),

                  Text(post.timeAgo, style: AppTextStyles.bodySmall),

                  if (post.description != null) ...[
                    const SizedBox(height: AppDimensions.spacing20),
                    Text(post.description!, style: AppTextStyles.bodyLarge),
                  ],

                  const SizedBox(height: AppDimensions.spacing20),

                  // Tags
                  if (post.tags.isNotEmpty)
                    Wrap(
                      spacing: AppDimensions.spacing8,
                      runSpacing: AppDimensions.spacing8,
                      children: post.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacing12,
                            vertical: AppDimensions.spacing8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium,
                            ),
                          ),
                          child: Text(tag, style: AppTextStyles.labelMedium),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
