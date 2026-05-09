import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:samak_fe/core/design_system/app_icons.dart';
import '../app_colors.dart';
import '../app_dimensions.dart';
import '../app_text_styles.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;
    const double contentHeight = AppDimensions.navigatorBarHeight;
    final double finalBottomGap = systemBottomPadding > 0 ? systemBottomPadding : 12.0;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFBFBFD),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        border: Border(
          top: BorderSide(color: AppColors.gray200, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: contentHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.navBarHorizontalPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: AppIcons.home,
                  selectedIcon: AppIcons.homeFilled,
                  label: '홈',
                  gap: 4
                ),
                _buildNavItem(
                  index: 1,
                  icon: AppIcons.heart,
                  selectedIcon: AppIcons.heartFilled,
                  label: '소식',
                  gap: 3,
                ),
                _buildNavItem(
                  index: 2,
                  icon: AppIcons.add,
                  selectedIcon: AppIcons.addFilled,
                  label: '분석',
                  gap: 5,
                ),
                _buildNavItem(
                  index: 3,
                  icon: AppIcons.chatDots,
                  selectedIcon: AppIcons.chatDotsFilled,
                  label: '게시판',
                  gap: 6,
                ),
                _buildNavItem(
                  index: 4,
                  icon: AppIcons.user,
                  selectedIcon: AppIcons.userFilled,
                  label: '프로필',
                  gap: 6,
                ),
              ],
            ),
          ),
          SizedBox(height: finalBottomGap),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String icon,
    required String selectedIcon,
    required String label,
    required double gap,
  }) {
    final bool isSelected = currentIndex == index;

    final String activeIcon = isSelected ? selectedIcon : icon;
    final Color contentColor = isSelected ? AppColors.gray900 : AppColors.gray500;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              activeIcon,
              colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
            ),
            SizedBox(height: gap),
            Text(
              label,
              style: AppTypography.small8.copyWith(color: contentColor),
            ),
          ],
        ),
      ),
    );
  }
}