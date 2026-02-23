import 'package:flutter/material.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/widgets/app_header.dart';
import '../data/models/city_model.dart';
import '../data/models/country_model.dart';
import '../screens/analysis_register.dart';
import '../screens/analysis_result.dart';
// API 연동
import '../data/repositories/analysis_repository.dart';
import '../data/models/analysis_item_list_model.dart';
import '../core/network/api_exception.dart';

// 신뢰도 강조 표시 기준: 70% 이상
const int _trustHighlightThreshold = 70;

// 정렬 모드
enum SortMode { trustHigh, trustLow, date }

// 분석 전체 리스트 화면
class AnalysisListScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const AnalysisListScreen({super.key, this.onBackToHome});

  @override
  State<AnalysisListScreen> createState() => _AnalysisListScreenState();
}

class _AnalysisListScreenState extends State<AnalysisListScreen> {
  List<AnalysisItemListModel> _items = [];
  bool _isLoading = true;
  String? _errorMessage;
  SortMode _sortMode = SortMode.date;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // 목록 조회 — trustLow는 RISK_SCORE로 받아 클라이언트에서 역순 처리
  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final sortType = _sortMode == SortMode.date
          ? AnalysisSortType.latest
          : AnalysisSortType.riskScore;
      final items = await AnalysisRepository.instance.getItems(sortType: sortType);
      setState(() => _items = items);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // _sampleItems → _items, 클라이언트 정렬은 trustLow만 유지
  // COMPLETED 아이템만 score 기준 정렬, 나머지는 항상 하단
  List<AnalysisItemListModel> get _filteredAndSortedItems {
    List<AnalysisItemListModel> result = _items
        .where((item) => item.companyName.contains(_searchQuery))
        .toList();

    if (_sortMode == SortMode.trustHigh || _sortMode == SortMode.trustLow) {
      var completed = result.where((e) => e.status == AnalysisStatus.completed).toList();
      final others = result.where((e) => e.status != AnalysisStatus.completed).toList();

      if (_sortMode == SortMode.trustHigh) {
        completed = completed.reversed.toList();
      }
      result = [...completed, ...others];
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: '분석 전체 리스트',
        showBackButton: true,
        onBack: widget.onBackToHome,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: AppTypography.middle14.copyWith(color: AppColors.gray500),
                textAlign: TextAlign.center,
              ),
            )
          :Column(
            children: [
          // ── 검색 바 ──
          Container(
            margin: EdgeInsetsGeometry.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPadding,
                vertical: 12,
              ),
              child: _SearchBar(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),

          // ── 정렬 버튼 ──
          Padding(
            padding: const EdgeInsets.only(
              right: AppDimensions.screenPadding,
              bottom: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 신뢰도 칩 — 높은순 → 낮은순 → 취소 순환
                _SortChip(
                  label: _sortMode == SortMode.trustHigh
                      ? '신뢰도 높은 순'
                      : _sortMode == SortMode.trustLow
                      ? '신뢰도 낮은 순'
                      : '신뢰도 순',
                  isSelected: _sortMode == SortMode.trustHigh || _sortMode == SortMode.trustLow,
                  onTap: () {
                    setState(() {
                      if (_sortMode == SortMode.trustHigh) {
                        _sortMode = SortMode.trustLow;
                      } else if (_sortMode == SortMode.trustLow) {
                        _sortMode = SortMode.date;
                      } else {
                        _sortMode = SortMode.trustHigh;
                      }
                    });
                    _loadItems();
                  },
                ),
                const SizedBox(width: 8),
                _SortChip(
                  label: '날짜 순',
                  isSelected: _sortMode == SortMode.date,
                  onTap: () {
                    setState(() => _sortMode = SortMode.date);
                    _loadItems();
                  },
                ),
              ],
            ),
          ),

          // ── 리스트 ──
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                0,
                AppDimensions.screenPadding,
                AppDimensions.screenPadding,
              ),
              itemCount: _filteredAndSortedItems.length,
              separatorBuilder: (_, __) => AppDimensions.verticalGap16,
              itemBuilder: (context, index) {
                return _AnalysisItemCard(item: _filteredAndSortedItems[index]);
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AnalysisRegisterScreen(
                onBack: () => Navigator.of(context).pop(),
                onGoToList: () => Navigator.of(context).pop(),
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// 검색 바 위젯
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(32),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTypography.middle14,
        decoration: InputDecoration(
          hintText: '회사명으로 공고 찾기',
          hintStyle: AppTypography.middle14.copyWith(color: AppColors.gray500),
          prefixIcon: const Icon(Icons.search, color: AppColors.gray500, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

// 정렬 칩 위젯
class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
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
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.small12.copyWith(
            color: isSelected ? AppColors.primary : AppColors.gray500,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// 공고 카드 위젯
class _AnalysisItemCard extends StatelessWidget {
  final AnalysisItemListModel item;

  const _AnalysisItemCard({required this.item});

  bool get _isHighTrust => (100- item.score) >= _trustHighlightThreshold;

  Color _statusColor(AnalysisStatus status) {
    switch (status) {
      case AnalysisStatus.pending:    return AppColors.gray500;
      case AnalysisStatus.processing: return AppColors.warning;
      case AnalysisStatus.completed:  return AppColors.success;
      case AnalysisStatus.failed:     return AppColors.error;
    }
  }

  String _statusLabel(AnalysisStatus status) {
    switch (status) {
      case AnalysisStatus.pending:    return '대기 중';
      case AnalysisStatus.processing: return '분석 중';
      case AnalysisStatus.completed:  return '분석 완료';
      case AnalysisStatus.failed:     return '분석 실패';
    }
  }

  @override
  Widget build(BuildContext context) {
    // createdAt → 'YYYY.MM.DD' 포맷 변환
    final examDate =
        '${item.createdAt.year}.${item.createdAt.month.toString().padLeft(2, '0')}.${item.createdAt.day.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: item.status == AnalysisStatus.completed ? () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AnalysisResultScreen(
              onBack: () => Navigator.of(context).pop(),
              analysisItemId: item.id,
              // resultData 제거 → analysisItemId 전달
            ),
          ),
        );
      } : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  item.companyName,
                  style: AppTypography.largeBold16.copyWith(letterSpacing: -0.5),
                ),
                const Spacer(),
                // 상태 뱃지
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(item.status),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    _statusLabel(item.status),
                    style: AppTypography.small12.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10,),
                // [MODIFIED] 분석 완료 상태일 때만 신뢰도 표시
                if (item.status == AnalysisStatus.completed) ...[
                  if (_isHighTrust) ...[
                    const Icon(Icons.check_circle, color: AppColors.info, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '신뢰도 ${100 - item.score}%',
                      style: AppTypography.small12.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    Text(
                      '신뢰도 ${100 - item.score}%',
                      style: AppTypography.small12.copyWith(color: AppColors.gray500),
                    ),
                  ],
                ],
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gray200, width: 1),
              ),
              child: Row(
                children: [
                  // '검사 날짜' → '등록 날짜'
                  _InfoColumn(label: '등록 날짜', value: examDate),
                  const Spacer(),
                  SizedBox(width: 1, height: 32),
                  const Spacer(),
                  // location → countryCode
                  _InfoColumn(
                    label: '국가 / 지역',
                    value: '${CountryModel.nameFromCode(item.countryCode)} / ${CityModel.nameFromId(item.cityId, fallback: '-')}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// 정보 컬럼 위젯 (검사 날짜 / 위치)
class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const _InfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.small12.copyWith(color: AppColors.gray500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.middle14.copyWith(letterSpacing: -0.3, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}