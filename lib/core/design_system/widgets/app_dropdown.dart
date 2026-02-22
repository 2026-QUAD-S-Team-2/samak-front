import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';
import '../app_icons.dart';

class AppDropdown extends StatefulWidget {
  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const AppDropdown({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  @override
  State<AppDropdown> createState() => _AppDropdownState();
}

class _AppDropdownState extends State<AppDropdown> {
  bool _isOpen = false;

  // [ADDED] 항목당 높이 및 최대 표시 항목 수 — 초과 시 내부 스크롤
  static const double _itemHeight = 48.0;
  static const int _maxVisibleItems = 4;

  void _toggle() => setState(() => _isOpen = !_isOpen);

  void _select(String item) {
    widget.onChanged(item);
    setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = widget.value != null;
    final double listHeight = (_itemHeight * widget.items.length)
        .clamp(0, _itemHeight * _maxVisibleItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 트리거 필드 ──
        GestureDetector(
          onTap: _toggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isOpen ? AppColors.primary : AppColors.gray300,
                width: _isOpen ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? widget.value! : widget.hintText,
                    style: AppTypography.middle14.copyWith(
                      color: hasValue ? AppColors.gray900 : AppColors.gray500,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: SvgPicture.asset(
                    AppIcons.arrowDown,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      _isOpen ? AppColors.primary : AppColors.gray500,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── 인라인 목록 — AnimatedSize로 펼침/접힘 ──
        if (_isOpen) const SizedBox(height: 4),
        AnimatedSize(
          duration: const Duration(milliseconds: 150), // [MODIFIED] 200 → 150
          curve: Curves.easeOut,                        // [MODIFIED] easeInOut → easeOut
          child: _isOpen
              ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary, width: 1.5), // [MODIFIED] top border 포함 전체 border
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7), // [MODIFIED] border 두께만큼 줄임
                child: Container(
                  height: listHeight,
                  color: Colors.white,
                  child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.items.length,
                itemBuilder: (_, index) {
                  final item = widget.items[index];
                  final bool isSelected = item == widget.value;
                  return GestureDetector(
                    onTap: () => _select(item),
                    child: Container(
                      height: _itemHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.purple050
                            : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item,
                              style: AppTypography.middle14.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.gray900,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ): const SizedBox.shrink(),
        ),
      ],
    );
  }
}