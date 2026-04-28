// lib/core/design_system/widgets/app_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_icons.dart';
import '../app_dimensions.dart';
import '../app_text_styles.dart';
import '../app_colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool showMenuButton;
  final VoidCallback? onMenuTap;
  final String? profileImageUrl;

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onBack,
    this.showMenuButton = false,
    this.onMenuTap,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Container(
          height: AppDimensions.topBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                "사막",
                style: AppTypography.large20,
              ),

              if (showBackButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: onBack,
                    child: SvgPicture.asset(
                      AppIcons.back,
                      width: 32,
                      height: 32,
                    ),
                  ),
                )
              else if (showMenuButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: onMenuTap,
                    child: SvgPicture.asset(
                      AppIcons.menu,
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(AppColors.gray900, BlendMode.srcIn),
                    ),
                  ),
                ),

              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (actions != null) ...actions!,
                    const SizedBox(width: 8),
                    ClipOval(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                            ? Image.network(profileImageUrl!, fit: BoxFit.cover)
                            : SvgPicture.asset(AppIcons.defaultProfile, fit: BoxFit.cover),
                      ),
                    ),
                  ],
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