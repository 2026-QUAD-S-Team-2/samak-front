// [ADDED] 게시글 목록 화면
// - 카테고리 필터 칩 (전체 / 경험담 / 사기 의심 투표 / 분석 결과 공유)
// - 키워드 검색 (클라이언트 사이드 필터링 — API 미지원)
// - 커서 기반 페이지네이션 (스크롤 하단 도달 시 추가 로드)
// - 게시글 등록 FAB
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design_system/app_icons.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/widgets/app_dialog.dart';
import '../data/repositories/board_repository.dart';
import '../data/models/board_model.dart';
import '../core/network/api_exception.dart';
import 'board_register.dart';
import 'board_detail.dart';

class BoardListScreen extends StatefulWidget {
  const BoardListScreen({super.key});

  @override
  State<BoardListScreen> createState() => _BoardListScreenState();
}

class _BoardListScreenState extends State<BoardListScreen> {
  // ── 데이터 상태 ──
  final List<BoardPostListItemModel> _items = [];
  int?  _nextCursor;
  bool  _hasNext      = false;
  bool  _isLoading    = true;
  bool  _isLoadingMore = false;

  // ── 필터/검색 상태 ──
  BoardCategory? _selectedCategory; // null = 전체
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 스크롤 하단 도달 시 다음 페이지 로드
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        _hasNext &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  // 첫 페이지 로드 (카테고리 변경 시에도 호출)
  Future<void> _loadInitial() async {
    setState(() {
      _items.clear();
      _nextCursor = null;
      _hasNext    = false;
      _isLoading  = true;
    });
    await _fetchPosts(isInitial: true);
  }

  // 다음 페이지 로드
  Future<void> _loadMore() async {
    if (!_hasNext || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await _fetchPosts(isInitial: false);
  }

  Future<void> _fetchPosts({required bool isInitial}) async {
    try {
      final result = await BoardRepository.instance.getPosts(
        category: _selectedCategory?.value,
        cursor:   isInitial ? null : _nextCursor,
        size:     10,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(result.data);
        _nextCursor = result.nextCursor;
        _hasNext    = result.hasNext;
      });
    } on ApiException catch (e) {
      if (mounted) {
        AppDialog.show(context, title: '불러오기 실패', message: e.message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading     = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  // 카테고리 선택 변경
  void _onCategoryChanged(BoardCategory? category) {
    if (_selectedCategory == category) return;
    setState(() => _selectedCategory = category);
    _loadInitial();
  }

  // 클라이언트 사이드 검색 필터
  List<BoardPostListItemModel> get _filteredItems {
    if (_searchQuery.isEmpty) return _items;
    return _items
        .where((item) => item.title.contains(_searchQuery))
        .toList();
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
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '게시글 목록',
                  style: AppTypography.large20.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '등록된 피해 사례를 확인하고 취업 사기를 예방해보아요.',
                  style: AppTypography.small12.copyWith(
                    color:         AppColors.gray500,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── 키워드 검색 ──
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPadding,
            ),
            child: _KeywordField(
              controller:  _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              onSubmitted: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),
          const SizedBox(height: 20),

          // ── 카테고리 필터 칩 ──
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPadding,
              ),
              children: [
                _CategoryChip(
                  label:      '전체',
                  isSelected: _selectedCategory == null,
                  onTap:      () => _onCategoryChanged(null),
                ),
                const SizedBox(width: 8),
                ...BoardCategory.values.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CategoryChip(
                    label:      c.label,
                    isSelected: _selectedCategory == c,
                    onTap:      () => _onCategoryChanged(c),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── 목록 / 로딩 / 빈 상태 ──
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_filteredItems.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  '게시글이 없습니다.',
                  style: AppTypography.middle14.copyWith(color: AppColors.gray500),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                controller:   _scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  0,
                  AppDimensions.screenPadding,
                  AppDimensions.screenPadding,
                ),
                itemCount:        _filteredItems.length + (_isLoadingMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 1),
                itemBuilder: (_, index) {
                  // 페이지네이션 로딩 인디케이터
                  if (index == _filteredItems.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    );
                  }
                  return _PostItemCard(
                    item:    _filteredItems[index],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BoardDetailScreen(
                          postId: _filteredItems[index].id,
                        ),
                      ),
                    ).then((_) => _loadInitial()),
                  );
                },
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BoardRegisterScreen()),
        ).then((_) => _loadInitial()),
        backgroundColor: AppColors.primary,
        shape:           const CircleBorder(),
        child:           const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// ── 카테고리 필터 칩 ──
class _CategoryChip extends StatelessWidget {
  final String       label;
  final bool         isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple050 : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray100,
            width: isSelected? 2 : 0,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.small12.copyWith(
            color:      isSelected ? AppColors.primary : AppColors.gray500,
            fontWeight: isSelected ? FontWeight.w600   : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ── 키워드 검색 필드 ──
class _KeywordField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>  onChanged;
  final ValueChanged<String>  onSubmitted;

  const _KeywordField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

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
        onChanged:       onChanged,
        onSubmitted:     onSubmitted,
        textInputAction: TextInputAction.search,
        style:           AppTypography.middle14,
        decoration: InputDecoration(
          hintText:  '키워드 검색',
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

// ── 게시글 목록 카드 ──
class _PostItemCard extends StatelessWidget {
  final BoardPostListItemModel item;
  final VoidCallback           onTap;

  const _PostItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color:  Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.gray200, width: 1),
            ),
            borderRadius: BorderRadius.circular(5)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 + 좋아요/댓글
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: AppTypography.middleBold15,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '스크랩 ${item.scrapCount}',
                      style: AppTypography.small12.copyWith(color: AppColors.gray500),
                    ),
                    const SizedBox(height: 10,),
                    Text(
                      '댓글 ${item.commentCount}',
                      style: AppTypography.large16.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // 카테고리 배지
            if (item.category != null)
              _CategoryBadge(category: item.category!),
          ],
        ),
      ),
    );
  }
}

// ── 카테고리 배지 ──
class _CategoryBadge extends StatelessWidget {
  final BoardCategory category;
  const _CategoryBadge({required this.category});

  // [MODIFIED] analysisShare 색상을 AppColors.primary로 변경 (경험담과 구분)
  Color get _color {
    switch (category) {
      case BoardCategory.experience:    return AppColors.info;
      case BoardCategory.fraudVote:     return AppColors.warning;
      case BoardCategory.analysisShare: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        _color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        category.label,
        style: AppTypography.small12.copyWith(
          color:      _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}