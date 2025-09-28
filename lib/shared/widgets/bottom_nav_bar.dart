import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_router.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.home); // Status page
        break;
      case 1:
        context.push(AppRouter.saved); // Saved page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF373631) : theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: AppDimensions.cardBlurRadius,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing32,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                Icons.photo_library_outlined,
                Icons.photo_library,
                0,
                AppStrings.navStatus,
              ),
              _buildNavItem(
                context,
                Icons.bookmark_border,
                Icons.bookmark,
                1,
                AppStrings.navSaved,
              ),
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
    String label,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing12,
          vertical: AppDimensions.spacing8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected
                  ? (isDarkMode ? Colors.white : theme.colorScheme.primary)
                  : (isDarkMode
                        ? Colors.white70
                        : theme.colorScheme.onSurfaceVariant),
              size: AppDimensions.iconMedium,
            ),
            const SizedBox(height: AppDimensions.spacing4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? (isDarkMode ? Colors.white : theme.colorScheme.primary)
                    : (isDarkMode
                          ? Colors.white70
                          : theme.colorScheme.onSurfaceVariant),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
