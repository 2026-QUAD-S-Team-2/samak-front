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
  final bool enableSearch;

  const AppDropdown({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.enableSearch = false,
  });

  @override
  State<AppDropdown> createState() => _AppDropdownState();
}

class _AppDropdownState extends State<AppDropdown> {
  bool _isOpen = false;

  static const double _itemHeight  = 48.0;
  static const int    _maxVisible  = 4;
  static const double _emptyHeight = 48.0;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode             _focusNode        = FocusNode();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
    // [MODIFIED] 포커스 손실 시 단순히 닫기만 처리 — 선택은 onTapDown에서만 담당
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isOpen) {
        _close();
      }
    });
  }

  @override
  void didUpdateWidget(AppDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = query.isEmpty
          ? widget.items
          : widget.items
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    });
  }

  void _open() {
    if (_isOpen) return;
    setState(() {
      _isOpen = true;
      _searchController.clear();
      _filteredItems = widget.items;
    });
    _focusNode.requestFocus();
  }

  void _close() {
    setState(() {
      _isOpen = false;
      _searchController.text = widget.value ?? '';
      _filteredItems = widget.items;
    });
    _focusNode.unfocus();
  }

  void _toggle() => _isOpen ? _close() : _open();

  // [MODIFIED] onTapDown에서만 선택 확정 — onTap 제거로 중복 실행 차단
  // onTapDown은 TextField 포커스 손실 이벤트보다 먼저 발생하므로
  // 포커스 리스너의 _close()가 호출되기 전에 선택이 완료됨
  void _commitSelection(String item) {
    // 리스너 일시 제거 → 컨트롤러 텍스트 설정 → 재등록 (_onSearchChanged 발동 방지)
    _searchController.removeListener(_onSearchChanged);
    _searchController.text = item;
    _filteredItems = List.from(widget.items);
    _searchController.addListener(_onSearchChanged);

    setState(() => _isOpen = false);
    _focusNode.unfocus();

    // 부모 rebuild가 가장 마지막에 일어나도록 onChanged를 맨 뒤에 호출
    widget.onChanged(item);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue   = widget.value != null && widget.value!.isNotEmpty;
    final displayItems    = widget.enableSearch ? _filteredItems : widget.items;
    final double listHeight = displayItems.isEmpty
        ? _emptyHeight
        : (_itemHeight * displayItems.length)
        .clamp(0, _itemHeight * _maxVisible);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 트리거 필드 ──
        GestureDetector(
          onTap: widget.enableSearch ? null : _toggle,
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
                  child: widget.enableSearch
                      ? TextField(
                    controller: _searchController,
                    focusNode:  _focusNode,
                    onTap:      _open,
                    onSubmitted: (_) {
                      if (_filteredItems.isNotEmpty) {
                        _commitSelection(_filteredItems.first);
                      }
                    },
                    style: AppTypography.middle14.copyWith(
                      color: AppColors.gray900,
                    ),
                    decoration: InputDecoration(
                      hintText: hasValue && !_isOpen
                          ? widget.value
                          : widget.hintText,
                      hintStyle: AppTypography.middle14.copyWith(
                        color: hasValue && !_isOpen
                            ? AppColors.gray900
                            : AppColors.gray500,
                      ),
                      border:         InputBorder.none,
                      isDense:        true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                      : Text(
                    hasValue ? widget.value! : widget.hintText,
                    style: AppTypography.middle14.copyWith(
                      color: hasValue
                          ? AppColors.gray900
                          : AppColors.gray500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _toggle,
                  child: AnimatedRotation(
                    turns:    _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: SvgPicture.asset(
                      AppIcons.arrowDown,
                      width:  20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        _isOpen ? AppColors.primary : AppColors.gray500,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── 인라인 목록 ──
        if (_isOpen) const SizedBox(height: 4),
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve:    Curves.easeOut,
          child: _isOpen
              ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Container(
                height: listHeight,
                color:  Colors.white,
                child: displayItems.isEmpty
                    ? Center(
                  child: Text(
                    '등록되지 않은 국가입니다.',
                    style: AppTypography.middle14
                        .copyWith(color: AppColors.gray500),
                  ),
                )
                    : ListView.builder(
                  padding:   EdgeInsets.zero,
                  itemCount: displayItems.length,
                  itemBuilder: (_, index) {
                    final item        = displayItems[index];
                    final bool isSelected = item == widget.value;
                    return GestureDetector(
                      // [MODIFIED] onTap 제거, onTapDown에서만 선택 확정
                      // — 포커스 손실(_close)보다 onTapDown이 먼저 실행되므로
                      //   중복 호출 없이 정확한 항목이 선택됨
                      onTapDown: (_) => _commitSelection(item),
                      child: Container(
                        height:  _itemHeight,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
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
                                style: AppTypography.middle14
                                    .copyWith(
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
                                size:  18,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}