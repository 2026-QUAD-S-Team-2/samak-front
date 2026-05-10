// lib/core/design_system/widgets/app_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_icons.dart';
import '../app_dimensions.dart';
import '../app_text_styles.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool showMenuButton;
  final VoidCallback? onMenuTap;
  final String? profileImageUrl;
  final VoidCallback? onProfileTap;

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onBack,
    this.showMenuButton = false,
    this.onMenuTap,
    this.profileImageUrl,
    this.onProfileTap
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
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showBackButton)
                      GestureDetector(
                        onTap: onBack,
                        child: SvgPicture.asset(AppIcons.back, width: 32, height: 32),
                      )
                    else if (showMenuButton)
                      GestureDetector(
                        onTap: onMenuTap,
                        child: SvgPicture.asset(AppIcons.menu, width: 24, height: 24),
                      ),

                    const SizedBox(width: 16),

                    SvgPicture.asset(AppIcons.appBarTitle, height: 24),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onProfileTap,
                  behavior: HitTestBehavior.opaque,
                  child: ClipOval(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                          ? Image.network(
                        profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => SvgPicture.asset(AppIcons.defaultProfile),
                      )
                          : SvgPicture.asset(AppIcons.defaultProfile),
                    ),
                  ),
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