// [MODIFIED] 피해 사례 조회 화면
// - 검색 유형: _SearchTypeButton(PopupMenu) → AppDropdown, 기본값 companyName, '전체' 제거
// - 에러 처리: _errorMessage 상태 변수 → AppDialog.show()
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design_system/app_icons.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/widgets/app_dialog.dart';
import '../data/repositories/report_repository.dart';
import '../data/models/report_model.dart';
import '../core/network/api_exception.dart';
import 'report_register.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  List<ReportListItemModel> _items = [];
  bool _isLoading = true;

  ReportSortType _sortType = ReportSortType.mostReported;
  // [MODIFIED] nullable → non-nullable, 기본값 companyName (전체 옵션 제거)
  ReportSearchType _searchType = ReportSearchType.companyName;

  final TextEditingController _keywordController = TextEditingController();

  // [ADDED] AppDropdown에 전달할 레이블 목록 (전체 제거, 열거형 순서 그대로 사용)
  static final List<String> _searchTypeLabels =
  ReportSearchType.values.map((e) => e.label).toList();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final keyword = _keywordController.text.trim();
      final items = await ReportRepository.instance.getReports(
        // 검색어가 없으면 searchType을 전송하지 않아 서버가 전체 조회하도록 처리
        searchType: keyword.isNotEmpty ? _searchType : null,
        sortType:   _sortType,
        keyword:    keyword.isNotEmpty ? keyword : null,
      );
      setState(() => _items = items);
    } on ApiException catch (e) {
      // [MODIFIED] 에러 상태 변수 제거 → AppDialog 팝업으로 고지
      if (mounted) {
        AppDialog.show(
          context,
          title:   '조회 실패',
          message: e.message,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── 섹션 헤더 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              16,
              AppDimensions.screenPadding,
              8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '피해 사례 조회',
                  style: AppTypography.largeBold16.copyWith(
                    fontSize:      20,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '등록된 피해 사례를 확인하고 취업 사기를 예방해보아요.',
                  style: AppTypography.small12.copyWith(
                    color:         AppColors.textSecondary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // ── 검색 영역 ──
          // [MODIFIED] Column(AppDropdown + KeywordField) → Row(_CompactDropdown + KeywordField)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPadding,
              vertical:   4,
            ),
            child: Row(
              children: [
                _CompactDropdown(
                  value:    _searchType.label,
                  hintText: '검색 유형',
                  items:    _searchTypeLabels,
                  onChanged: (label) {
                    final type = ReportSearchType.values
                        .firstWhere((t) => t.label == label);
                    setState(() => _searchType = type);
                    if (_keywordController.text.trim().isNotEmpty) _loadItems();
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _KeywordField(
                    controller:  _keywordController,
                    onSubmitted: (_) => _loadItems(),
                  ),
                ),
              ],
            ),
          ),

          // ── 정렬 칩 ──
          Padding(
            padding: const EdgeInsets.only(
              left:   AppDimensions.screenPadding,
              right:  AppDimensions.screenPadding,
              bottom: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _SortChip(
                  label:      '신고 많은 순',
                  isSelected: _sortType == ReportSortType.mostReported,
                  onTap: () {
                    setState(() => _sortType = ReportSortType.mostReported);
                    _loadItems();
                  },
                ),
                const SizedBox(width: 8),
                _SortChip(
                  label:      '최근 신고 순',
                  isSelected: _sortType == ReportSortType.latest,
                  onTap: () {
                    setState(() => _sortType = ReportSortType.latest);
                    _loadItems();
                  },
                ),
              ],
            ),
          ),

          // ── 목록 / 로딩 / 빈 상태 ──
          // [MODIFIED] _errorMessage 분기 제거 (에러는 AppDialog로 처리)
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_items.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  '등록된 피해 사례가 없습니다.',
                  style: AppTypography.middle14.copyWith(color: AppColors.gray500),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  0,
                  AppDimensions.screenPadding,
                  AppDimensions.screenPadding,
                ),
                itemCount:        _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) =>
                    _ReportItemCard(item: _items[index]),
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (_) => ReportRegisterScreen(
            onBack: () => Navigator.of(context).pop(),
          ),
        ))
            .then((_) => _loadItems()),
        backgroundColor: AppColors.primary,
        shape:           const CircleBorder(),
        child:           const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// ── 검색어 입력 필드 ──
class _KeywordField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>  onSubmitted;

  const _KeywordField({required this.controller, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: AppColors.gray300),
      ),
      child: TextField(
        controller:      controller,
        onSubmitted:     onSubmitted,
        textInputAction: TextInputAction.search,
        style:           AppTypography.middle14,
        decoration: InputDecoration(
          hintText:       '검색어를 입력해 주세요',
          hintStyle:      AppTypography.middle14.copyWith(color: AppColors.gray500),
          prefixIcon:     const Icon(Icons.search, color: AppColors.gray500, size: 20),
          border:         InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

// ── 정렬 칩 (analysis_list.dart의 _SortChip과 동일한 패턴) ──
class _SortChip extends StatelessWidget {
  final String       label;
  final bool         isSelected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color:        isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.small12.copyWith(
            color:      isSelected ? AppColors.primary : AppColors.gray500,
            fontWeight: isSelected ? FontWeight.w600  : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ── 피해 사례 목록 카드 ──
class _ReportItemCard extends StatelessWidget {
  final ReportListItemModel item;

  const _ReportItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${item.latestReportedAt.year}.${item.latestReportedAt.month.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.companyName,
                  style: AppTypography.largeBold16.copyWith(letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  '최근 신고 $dateStr',
                  style: AppTypography.small12.copyWith(color: AppColors.gray500),
                ),
              ],
            ),
          ),
          Text(
            '신고 ${item.reportCount}건',
            style: AppTypography.largeBold16.copyWith(
              color:         AppColors.error,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// [ADDED] 가로 배치용 소형 드롭다운
// AppDropdown과 동일한 시각 스타일이지만 showMenu(플로팅 오버레이)로 열려
// Row 레이아웃에서도 주변 위젯에 영향을 주지 않음
class _CompactDropdown extends StatelessWidget {
  final String        value;
  final String        hintText;
  final List<String>  items;
  final ValueChanged<String> onChanged;

  const _CompactDropdown({
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  void _showMenu(BuildContext context) {
    final button  = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context:  context,
      position: position,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.white,
      items: items.map((item) {
        final bool isSelected = item == value;
        return PopupMenuItem<String>(
          value: item,
          height: 44,
          child: Text(
            item,
            style: AppTypography.middle14.copyWith(
              color:      isSelected ? AppColors.primary : AppColors.gray900,
              fontWeight: isSelected ? FontWeight.w600   : FontWeight.w400,
            ),
          ),
        );
      }).toList(),
    ).then((selected) {
      if (selected != null) onChanged(selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: Container(
        height: 44,  // _KeywordField와 높이 통일
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTypography.middle14.copyWith(
                color:      AppColors.gray900,
              ),
            ),
            const SizedBox(width: 4),
            SvgPicture.asset(
              AppIcons.arrowDown,
              width:  16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}