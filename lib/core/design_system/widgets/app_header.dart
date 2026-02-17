// lib/core/design_system/widgets/app_header.dart
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_dimensions.dart';
import '../app_text_styles.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Container(
          height: AppDimensions.topBarHeight, // 64px
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                title,
                style: AppTypography.large20,
              ),

              if (showBackButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    // TODO: 아이콘 - AppIcons.back (ic_back.svg) 사용으로 변경
                    icon: const Icon(
                      Icons.chevron_left,
                      size: 28,
                      color: AppColors.gray900,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: onBack,
                  ),
                ),

              if (actions != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.totalTopHeight);
}