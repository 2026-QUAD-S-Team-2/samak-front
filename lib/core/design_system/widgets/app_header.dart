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
          height: AppDimensions.topBarHeight,
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
                  child: GestureDetector(
                    onTap: onBack,
                    child: SvgPicture.asset(
                      AppIcons.back,
                      width: 32,
                      height: 32,
                    ),
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