import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return Container(
      height: AppDimensions.navigatorBarHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        border: Border(
          top: BorderSide(color: AppColors.gray200, width: 1),
          left: BorderSide(color: AppColors.gray200, width: 1),
          right: BorderSide(color: AppColors.gray200, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.navBarHorizontalPadding,
        vertical: AppDimensions.navBarVerticalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(index: 0, icon: 'assets/icons/ic_home.svg', label: '홈', gap: 4),
          _buildNavItem(index: 1, icon: 'assets/icons/ic_heart.svg', label: '소식', gap: 7),
          _buildNavItem(index: 2, icon: 'assets/icons/ic_add.svg', label: '분석', gap: 5),
          _buildNavItem(index: 3, icon: 'assets/icons/ic_chat-dots.svg', label: '게시판', gap: 6),
          _buildNavItem(index: 4, icon: 'assets/icons/ic_user.svg', label: '프로필', gap: 6),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String icon,
    required String label,
    required double gap,
  }) {
    final bool isSelected = currentIndex == index;
    final Color contentColor = isSelected ? AppColors.gray900 : AppColors.gray500;

    return Expanded( // 5등분을 위해 Expanded 사용
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
              width: 18, // 아이콘 크기는 적절히 조절
              height: 18,
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