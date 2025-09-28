import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/whatsapp_status.dart';
import '../../../../shared/widgets/app_scaffold.dart';

import '../viewmodels/whatsapp_status_view_model.dart';
import '../widgets/whatsapp_status_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WhatsAppStatusViewModel(),
      child: const _FeedScreenContent(),
    );
  }
}

class _FeedScreenContent extends StatefulWidget {
  const _FeedScreenContent();

  @override
  State<_FeedScreenContent> createState() => _FeedScreenContentState();
}

class _FeedScreenContentState extends State<_FeedScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final viewModel = Provider.of<WhatsAppStatusViewModel>(
          context,
          listen: false,
        );
        viewModel.selectTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
              Icons.settings_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: AppDimensions.spacing8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Images'),
            Tab(text: 'Videos'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          dividerColor: Colors.transparent,
          labelStyle: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.titleSmall,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(0), // Images tab
          _buildTabContent(1), // Videos tab
        ],
      ),
    );
  }

  Widget _buildTabContent(int tabIndex) {
    return Consumer<WhatsAppStatusViewModel>(
      builder: (context, viewModel, _) {
        // Check permission first
        if (!viewModel.hasPermission) {
          return _buildPermissionRequiredScreen(context, viewModel);
        }

        // Show loading
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        // Show error if any
        if (viewModel.errorMessage != null) {
          return _buildErrorScreen(context, viewModel);
        }

        // Get statuses for the specific tab
        final statuses = viewModel.getStatusesForTab(tabIndex);

        // Show empty state if no statuses
        if (statuses.isEmpty) {
          return _buildEmptyState(context, tabIndex);
        }

        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.refreshStatuses();
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.gridSpacing,
              mainAxisSpacing: AppDimensions.gridSpacing,
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final status = statuses[index];
                return WhatsAppStatusCard(
                  status: status,
                  onTap: () => _onStatusTap(context, status),
                  onSave: () => _onSaveStatus(context, status, viewModel),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionRequiredScreen(
    BuildContext context,
    WhatsAppStatusViewModel viewModel,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Permission Required',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'We need storage permission to access WhatsApp status files.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing24),
            ElevatedButton(
              onPressed: () => viewModel.requestPermission(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing24,
                  vertical: AppDimensions.spacing12,
                ),
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(
    BuildContext context,
    WhatsAppStatusViewModel viewModel,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Error',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              viewModel.errorMessage ?? 'An unexpected error occurred.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing24),
            ElevatedButton(
              onPressed: () => viewModel.refreshStatuses(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing24,
                  vertical: AppDimensions.spacing12,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, int tabIndex) {
    final isImageTab = tabIndex == 0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isImageTab ? Icons.image_outlined : Icons.video_library_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'No ${isImageTab ? 'Images' : 'Videos'} Found',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'No WhatsApp status ${isImageTab ? 'images' : 'videos'} available.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onStatusTap(BuildContext context, WhatsAppStatus status) {
    // Navigate to full screen view or show details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opened ${status.type == StatusType.video ? 'video' : 'image'} status',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _onSaveStatus(
    BuildContext context,
    WhatsAppStatus status,
    WhatsAppStatusViewModel viewModel,
  ) async {
    try {
      await viewModel.saveStatus(status);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${status.type == StatusType.video ? 'Video' : 'Image'} saved successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
