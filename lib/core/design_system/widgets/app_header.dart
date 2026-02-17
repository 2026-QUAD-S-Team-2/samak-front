// lib/core/design_system/widgets/app_header.dart
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_dimensions.dart';
import '../app_text_styles.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea( // Status Bar (52px) 영역 확보
        child: Container(
          height: AppDimensions.topBarHeight, // 64px
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Text(
                title,
                style: AppTypography.large20,
              ),
              const Spacer(),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.totalTopHeight);
}