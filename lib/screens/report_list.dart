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

  // 수정 후
  Future<void> _loadItems() async {
    final keyword = _keywordController.text.trim();
    // [MODIFIED] keyword는 API required 파라미터이므로 없으면 API 호출 생략
    if (keyword.isEmpty) {
      setState(() {
        _items     = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final items = await ReportRepository.instance.getReports(
        searchType: _searchType,
        sortType:   _sortType,
        keyword:    keyword,
      );
      setState(() => _items = items);
    } on ApiException catch (e) {
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
              24, 28, 24, 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '피해 사례 조회',
                  style: AppTypography.large20.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '등록된 피해 사례를 확인하고 취업 사기를 예방해보아요.',
                  style: AppTypography.small12.copyWith(
                    color: AppColors.gray500,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18,),
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

          const SizedBox(height: 20),

          // ── 정렬 칩 ──
          Padding(
            padding: const EdgeInsets.only(
              left:   AppDimensions.screenPadding,
              right:  AppDimensions.screenPadding,
              bottom: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                  // [MODIFIED] 키워드 없을 때와 검색 결과 없을 때 메시지 구분
                  _keywordController.text.trim().isEmpty
                      ? '검색어를 입력하고 조회해주세요.'
                      : '검색 결과가 없습니다.',
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

  // [MODIFIED] white → gray100, radius 8 → 32, border 제거, Icon → SvgPicture(gray500 tint)
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color:        AppColors.gray100,
        borderRadius: BorderRadius.circular(32),
      ),
      child: TextField(
        controller:      controller,
        onSubmitted:     onSubmitted,
        textInputAction: TextInputAction.search,
        style:           AppTypography.middle14,
        decoration: InputDecoration(
          hintText:  '검색어를 입력해 주세요',
          hintStyle: AppTypography.middle14.copyWith(color: AppColors.gray500),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              AppIcons.search,
              width:  20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.gray500,
                BlendMode.srcIn,
              ),
            ),
          ),
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
      // [MODIFIED] borderRadius 20 → 50, 선택 시 fill Colors.white → purple050
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple050 : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
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

  // [MODIFIED] white → gray100, radius 8 → 32, 파란 border 제거
// [ADDED] ic_search_type 아이콘, arrowDown tint gray500으로 변경
// [ADDED] value 없을 때 hintText(gray500) 표시
  @override
  Widget build(BuildContext context) {
    final bool hasValue = value.isNotEmpty;
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color:        AppColors.gray100,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppIcons.searchType,
              width:  18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                AppColors.gray500,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              hasValue ? value : hintText,
              style: AppTypography.middle14.copyWith(
                color: hasValue ? AppColors.gray900 : AppColors.gray500,
              ),
            ),
            const SizedBox(width: 4),
            SvgPicture.asset(
              AppIcons.arrowDown,
              width:  16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.gray500,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}