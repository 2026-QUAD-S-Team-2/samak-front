import 'package:flutter/material.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/widgets/app_header.dart';

// 데이터 모델
class AnnouncementItem {
  final String companyName;
  final int trustScore; // 0 ~ 100
  final String examDate; // 'YYYY.MM.DD'
  final String location;

  const AnnouncementItem({
    required this.companyName,
    required this.trustScore,
    required this.examDate,
    required this.location,
  });
}

// ─────────────────────────────────────────────
// 샘플 데이터
// ─────────────────────────────────────────────
const List<AnnouncementItem> _sampleItems = [
  AnnouncementItem(companyName: '삼은 반도체', trustScore: 13,  examDate: '2026.02.01', location: '중국, 북경'),
  AnnouncementItem(companyName: '현대 건설',   trustScore: 100, examDate: '2026.02.04', location: '한국, 서울'),
  AnnouncementItem(companyName: '카카오',     trustScore: 27,  examDate: '2026.02.01', location: '중국, 북경'),
  AnnouncementItem(companyName: '네이버',     trustScore: 94,  examDate: '2026.02.04', location: '한국, 서울'),
  AnnouncementItem(companyName: '삼원 전자',   trustScore: 61,  examDate: '2026.02.10', location: '한국, 부산'),
];

// 신뢰도 강조 표시 기준: 70% 이상
const int _trustHighlightThreshold = 70;

// 정렬 모드
enum SortMode { trust, date }

// 분석 전체 리스트 화면
class AnalysisListScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const AnalysisListScreen({super.key, this.onBackToHome});

  @override
  State<AnalysisListScreen> createState() => _AnalysisListScreenState();
}

class _AnalysisListScreenState extends State<AnalysisListScreen> {
  SortMode _sortMode = SortMode.date;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AnnouncementItem> get _filteredAndSortedItems {
    List<AnnouncementItem> result = _sampleItems.where((item) {
      return item.companyName.contains(_searchQuery);
    }).toList();

    if (_sortMode == SortMode.trust) {
      result.sort((a, b) => b.trustScore.compareTo(a.trustScore));
    } else {
      result.sort((a, b) => b.examDate.compareTo(a.examDate));
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
      body: Column(
        children: [
          // ── 검색 바 ──
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPadding,
              vertical: 12,
            ),
            child: _SearchBar(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // ── 정렬 버튼 ──
          Padding(
            padding: const EdgeInsets.only(
              right: AppDimensions.screenPadding,
              bottom: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _SortChip(
                  labelDefault: '신뢰도 순',
                  labelSelected: '신뢰도 높은 순',
                  isSelected: _sortMode == SortMode.trust,
                  onTap: () => setState(() => _sortMode = SortMode.trust),
                ),
                const SizedBox(width: 8),
                _SortChip(
                  labelDefault: '날짜순',
                  labelSelected: '날짜 순',
                  isSelected: _sortMode == SortMode.date,
                  onTap: () => setState(() => _sortMode = SortMode.date),
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
                return _AnnouncementCard(item: _filteredAndSortedItems[index]);
              },
            ),
          ),
        ],
      ),

      // TODO: FAB 탭 시 공고 추가 화면으로 이동 연결 필요 (추후 구현)
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200, width: 1),
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
  final String labelDefault;
  final String labelSelected;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortChip({
    required this.labelDefault,
    required this.labelSelected,
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
          isSelected ? labelSelected : labelDefault,
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
class _AnnouncementCard extends StatelessWidget {
  final AnnouncementItem item;

  const _AnnouncementCard({required this.item});

  bool get _isHighTrust => item.trustScore >= _trustHighlightThreshold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 회사명 + 신뢰도 ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                item.companyName,
                style: AppTypography.largeBold16.copyWith(letterSpacing: -0.5),
              ),
              const Spacer(),
              if (_isHighTrust) ...[
                const Icon(Icons.check_circle, color: AppColors.info, size: 16),
                const SizedBox(width: 4),
                Text(
                  '신뢰도 ${item.trustScore}%',
                  style: AppTypography.small12.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                Text(
                  '신뢰도 ${item.trustScore}%',
                  style: AppTypography.small12.copyWith(color: AppColors.gray500),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // ── 검사 날짜 / 위치 상세 박스 ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gray200, width: 1),
            ),
            child: Row(
              children: [
                _InfoColumn(label: '검사 날짜', value: item.examDate),
                const Spacer(),
                Container(width: 1, height: 32, color: AppColors.gray200),
                const Spacer(),
                _InfoColumn(label: '위치', value: item.location),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
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
          style: AppTypography.small10.copyWith(color: AppColors.gray500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.middle14.copyWith(letterSpacing: -0.3),
        ),
      ],
    );
  }
}