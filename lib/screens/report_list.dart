import 'package:flutter/material.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
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
  String? _errorMessage;
  ReportSortType    _sortType   = ReportSortType.mostReported;
  ReportSearchType? _searchType;                              // null = 전체
  final TextEditingController _keywordController = TextEditingController();

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
    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });
    try {
      final keyword = _keywordController.text.trim();
      final items = await ReportRepository.instance.getReports(
        searchType: keyword.isNotEmpty ? _searchType : null,
        sortType:   _sortType,
        keyword:    keyword.isNotEmpty ? keyword : null,
      );
      setState(() => _items = items);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
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
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '등록된 피해 사례를 확인하고 취업 사기를 예방해보아요.',
                  style: AppTypography.small12.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // ── 검색 영역: [검색 유형 선택] + [검색어 입력] ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              4,
              AppDimensions.screenPadding,
              4,
            ),
            child: Row(
              children: [
                _SearchTypeButton(
                  selectedType: _searchType,
                  onSelected: (type) {
                    setState(() => _searchType = type);
                    // 이미 검색어가 있는 경우 유형 변경 시 즉시 재조회
                    if (_keywordController.text.trim().isNotEmpty) {
                      _loadItems();
                    }
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _KeywordField(
                    controller: _keywordController,
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

          // ── 목록 / 로딩 / 에러 / 빈 상태 ──
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Text(
                  _errorMessage!,
                  style: AppTypography.middle14.copyWith(color: AppColors.gray500),
                  textAlign: TextAlign.center,
                ),
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

      // ── 등록 플로팅 버튼 ──
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (_) => ReportRegisterScreen(
            onBack: () => Navigator.of(context).pop(),
          ),
        ))
            .then((_) => _loadItems()), // 등록 완료 후 목록 갱신
        backgroundColor: AppColors.primary,
        shape:           const CircleBorder(),
        child:           const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// ── 검색 유형 선택 버튼 ──
// PopupMenuButton을 활용해 전체/회사명/이메일/텔레그램/전화 중 선택
class _SearchTypeButton extends StatelessWidget {
  final ReportSearchType?            selectedType;
  final ValueChanged<ReportSearchType?> onSelected;

  const _SearchTypeButton({
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = selectedType != null;
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == '__ALL__') {
          onSelected(null);
        } else {
          onSelected(
            ReportSearchType.values.firstWhere((t) => t.value == value),
          );
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem<String>(value: '__ALL__', child: Text('전체')),
        ...ReportSearchType.values.map(
              (t) => PopupMenuItem<String>(value: t.value, child: Text(t.label)),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.gray300,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              size:  16,
              color: isActive ? AppColors.primary : AppColors.gray500,
            ),
            const SizedBox(width: 4),
            Text(
              selectedType?.label ?? '검색 유형',
              style: AppTypography.small12.copyWith(
                color:      isActive ? AppColors.primary : AppColors.gray500,
                fontWeight: isActive ? FontWeight.w600  : FontWeight.w400,
              ),
            ),
          ],
        ),
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
          hintText:  '검색어를 입력해 주세요',
          hintStyle: AppTypography.middle14.copyWith(color: AppColors.gray500),
          prefixIcon: const Icon(Icons.search, color: AppColors.gray500, size: 20),
          border:           InputBorder.none,
          contentPadding:   const EdgeInsets.symmetric(vertical: 12),
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
          // 좌측: 회사명 + 최근 신고 날짜
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
          // 우측: 신고 건수
          Text(
            '신고 ${item.reportCount}건',
            style: AppTypography.largeBold16.copyWith(
              color:        AppColors.error,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}