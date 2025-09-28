import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/navigation/app_router.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        context.go(AppRouter.search);
        break;
      case 2:
        context.go(AppRouter.add);
        break;
      case 3:
        context.go(AppRouter.messages);
        break;
      case 4:
        context.go(AppRouter.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: AppDimensions.cardBlurRadius,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_outlined, Icons.home_filled, 0),
              _buildNavItem(context, Icons.search_outlined, Icons.search, 1),
              _buildAddButton(context),
              _buildNavItem(
                context,
                Icons.chat_bubble_outline,
                Icons.chat_bubble,
                3,
              ),
              _buildNavItem(context, Icons.person_outline, Icons.person, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData outlineIcon,
    IconData filledIcon,
    int index,
  ) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing12,
          vertical: AppDimensions.spacing8,
        ),
        child: Icon(
          isSelected ? filledIcon : outlineIcon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: AppDimensions.iconMedium,
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _onItemTapped(context, 2),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: selectedIndex == 2
              ? AppColors.primary
              : AppColors.textSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: const Icon(
          Icons.add,
          color: AppColors.surface,
          size: AppDimensions.iconMedium,
        ),
      ),
    );
  }
}
