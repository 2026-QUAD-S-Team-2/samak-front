import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/app_icons.dart';
import 'package:url_launcher/url_launcher.dart';
// API 연동
import '../data/repositories/member_repository.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/models/member_model.dart';
import '../data/models/quiz_model.dart';
import '../core/network/api_exception.dart';
import '../data/repositories/news_repository.dart';
import '../data/models/news_model.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const HomeScreen({super.key, this.onProfileTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 멤버/퀴즈 데이터 상태
  MemberModel? _member;
  TodayQuizModel? _quiz;
  List<NewsModel> _newsList = [];
  // String? _homeError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 멤버 정보 + 퀴즈 병렬 로드
  /* Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        MemberRepository.instance.getMe(),
        QuizRepository.instance.getTodayQuiz(),
        NewsRepository.instance.getBannerNews(),
      ]);
      // debugPrint('member raw: ${results[0]}');
      setState(() {
        _member = results[0] as MemberModel;
        _quiz   = results[1] as TodayQuizModel;
        _newsList = results[2] as List<NewsModel>;
      });
      // debugPrint('newsList: ${_newsList.map((e) => e.title).toList()}');
    } on ApiException catch (e) {
      // setState(() => _homeError = e.message);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
    /*
    catch (e) {
      // ApiException 외 예외도 확인
      setState(() => _homeError = e.toString());
    }
    */
  }

   */

  Future<void> _loadData() async {
    // 1. 사용자 정보 로드 (필수)
    try {
      final member = await MemberRepository.instance.getMe();
      setState(() => _member = member);
    } catch (e) {
      debugPrint('사용자 정보 로드 실패: $e');
    }

    // 2. 퀴즈 정보 로드 (실패해도 앱은 돌아가게)
    try {
      final quiz = await QuizRepository.instance.getTodayQuiz();
      setState(() => _quiz = quiz);
    } catch (e) {
      debugPrint('퀴즈 로드 실패: $e');
    }

    // 3. 뉴스 정보 로드
    try {
      final news = await NewsRepository.instance.getBannerNews();
      setState(() => _newsList = news);
    } catch (e) {
      debugPrint('뉴스 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: statusBarHeight + AppDimensions.bottomSafeArea),
            AppDimensions.verticalGap16,
            Padding(
              padding: AppDimensions.screenEdgePadding,
              child: _BannerCard(newsList: _newsList,),
            ),
            AppDimensions.verticalGap24,
            _AnnouncementSection(),
            AppDimensions.verticalGap24,
            _QuizSection(quiz: _quiz),
            AppDimensions.verticalGap24,
          ],
        ),
      ),
    );
  }
}

class _BannerCard extends StatefulWidget {
  final List<NewsModel> newsList; // [ADDED]

  const _BannerCard({required this.newsList});

  @override
  State<_BannerCard> createState() => _BannerCardState();
  // [ADDED] 임시 디버그 로그 — 확인 후 제거
}

class _BannerCardState extends State<_BannerCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 서버 데이터가 없으면(서버 불안정 등) 하드코딩 배너 1개 띄움
    final bool showFallback = widget.newsList.isEmpty;
    final int totalCount = showFallback ? 1 : widget.newsList.length;

    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalCount,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (_, index) {

              // 서버 데이터가 없어 폴백(하드코딩) 배너를 띄워야 하는 경우
              if (showFallback) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '취업 사기가 걱정되시나요?',
                                style: AppTypography.large16.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '사막 AI 분석이 공고를 검증해 드려요',
                                style: AppTypography.middle13.copyWith(
                                  color: AppColors.purple100,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(12),
                        ),
                        child: Image(
                          image: AssetImage(AppIcons.banner),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 서버 데이터를 정상적으로 받아온 경우
              final news = widget.newsList[index];

              return GestureDetector(
                onTap: () => _openLink(news.link),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(news.backgroundImageUrl),
                      fit: BoxFit.fitHeight,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        news.title,
                        style: AppTypography.largeBold16.copyWith(
                          color: index == 0 ? AppColors.purple100 : AppColors.gray900,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        news.summary,
                        style: AppTypography.small12.copyWith(
                          color: index == 0 ? AppColors.gray200 : AppColors.textSecondary,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // ── 페이지 인디케이터 도트 ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalCount, (index) {
            final bool isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.gray300,
                borderRadius: BorderRadius.circular(100),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _AnnouncementSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. 섹션 헤더 (Flexible/Expanded 적용으로 오버플로우 방지) ──
        Padding(
          padding: AppDimensions.screenEdgePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 첫 번째 줄: 타이틀 + 숫자 배지
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '공고 확인',
                    style: AppTypography.largeBold16.copyWith(
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.purple100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '2',
                      style: AppTypography.smallBold12.copyWith(
                        color: AppColors.purple500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6), // 타이틀과 설명 사이 간격
              // 두 번째 줄: 설명 텍스트
              Text(
                '김땡땡 님이 관심 있는 분야의 공고가 올라왔어요',
                style: AppTypography.small12.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── 2. 아이템 박스 ──
        Container(
          margin: AppDimensions.screenEdgePadding,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            children: [
              _AnnouncementCard(
                companyName: '\'OO회사\' 공고',
                dateRange: '2.01 - 2.24',
                memberCount: 3,
                hasMoreMembers: true,
                isActive: true,
              ),
              AppDimensions.verticalGap12,
              _AnnouncementCard(
                companyName: '\'OOO회사\' 공고',
                dateRange: '2.08 - 2.26',
                memberCount: 3,
                hasMoreMembers: false,
                isActive: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final String companyName;
  final String dateRange;
  final int memberCount;
  final bool hasMoreMembers;
  final bool isActive;

  const _AnnouncementCard({
    required this.companyName,
    required this.dateRange,
    required this.memberCount,
    required this.hasMoreMembers,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gray200,
          width: 1
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  style: AppTypography.middle14.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5
                  ),
                ),
                const SizedBox(height: 12,),

                SizedBox(
                  height: 28, // 아바타 높이에 맞춤
                  child: Stack(
                    children: [
                      ...List.generate(
                        memberCount + (hasMoreMembers ? 1 : 0),
                            (index) {
                          if (index == memberCount && hasMoreMembers) {
                            return Positioned(
                              left: index * 20.0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.gray200,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2), // 경계선 추가
                                ),
                                child: Center(
                                  child: Text(
                                    '+3',
                                    style: AppTypography.small10.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            );
                          }

                          // 일반 아바타 배치
                          return Positioned(
                            left: index * 20.0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: isActive ? AppColors.gray900 : AppColors.gray300,
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16,),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.clock,
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 4,),
                  Text(
                    dateRange,
                    style: AppTypography.small12.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: -0.5
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8,),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.purple600,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '분석하기',
                  style: AppTypography.small10.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

// quiz 파라미터 추가
class _QuizSection extends StatefulWidget {
  final TodayQuizModel? quiz;
  const _QuizSection({this.quiz});

  @override
  State<_QuizSection> createState() => _QuizSectionState();
}

class _QuizSectionState extends State<_QuizSection> {
  // 답변 제출 후 결과 상태
  QuizAnswerModel? _answerResult;
  bool _isSubmitting = false;
  bool? _userAnswer;

  // O/X 버튼 탭 → 답변 제출
  // 선택한 답변 저장 추가
  Future<void> _submitAnswer(bool answer) async {
    if (_isSubmitting || widget.quiz == null) return;
    setState(() {
      _isSubmitting = true;
      _userAnswer = answer;
    });
    try {
      final result = await QuizRepository.instance.submitAnswer(answer);
      setState(() => _answerResult = result);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.quiz;

    // 이미 풀었거나 방금 제출한 경우 → 결과 표시 여부 판단
    final bool isSolved  = quiz?.isSolved == true || _answerResult != null;
    final bool isCorrect = _answerResult?.isCorrect ?? quiz?.isCorrect ?? false;
    final String explanation = _answerResult?.explanation ?? '';
    // 정답값 — 방금 제출했으면 correctAnswer, 이미 풀었으면 quiz.answer
    final bool? correctAnswer = _answerResult?.correctAnswer ??
        (quiz?.isSolved == true ? quiz?.answer : null);

    return Container(
      margin: AppDimensions.screenEdgePadding,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: AppDimensions.screenEdgePadding,
            child: Row(
              children: [
                Flexible(child: Text(
                  '오늘의 퀴즈',
                  style: AppTypography.largeBold16.copyWith(letterSpacing: -0.5),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.purple100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '1',
                    style: AppTypography.smallBold12.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: AppDimensions.screenEdgePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 퀴즈 질문
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gray200, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.bolt, color: Colors.white, size: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          quiz?.question ?? '퀴즈를 불러오는 중...',
                          style: AppTypography.middle14.copyWith(letterSpacing: -0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 풀이 완료 시 해설 표시
                if (isSolved && explanation.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfacePrimary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCorrect ? AppColors.success : AppColors.error,
                        width: 1,
                      )
                    ),
                    child: Text(
                      explanation,
                      style: AppTypography.small12.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                        letterSpacing: -0.2
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // O/X 버튼
                Row(
                  children: [
                    Expanded(
                      // 탭 → _submitAnswer(false), isSolved 시 비활성화
                      child: GestureDetector(
                        onTap: isSolved ? null : () => _submitAnswer(false),
                        child: _QuizButton(
                          label: 'X',
                          state: !isSolved
                              ? _QuizButtonState.idle
                              : correctAnswer == false
                              ? _QuizButtonState.correct
                              : _userAnswer == false
                              ? _QuizButtonState.wrong
                              : _QuizButtonState.idle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      // 탭 → _submitAnswer(true), isSolved 시 비활성화
                      child: GestureDetector(
                        onTap: isSolved ? null : () => _submitAnswer(true),
                        child: _QuizButton(
                          label: 'O',
                          state: !isSolved
                              ? _QuizButtonState.idle
                              : correctAnswer == true
                              ? _QuizButtonState.correct
                              : _userAnswer == true
                              ? _QuizButtonState.wrong
                              : _QuizButtonState.idle,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isSolved) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      '오늘의 퀴즈는 이미 풀었어요. 내일 다시 도전해 보세요!',
                      style: AppTypography.small12.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    )
                  )
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 퀴즈 버튼 위젯
// 버튼 상태 enum
enum _QuizButtonState { idle, correct, wrong }

// isCorrect(bool) → state(_QuizButtonState)
class _QuizButton extends StatelessWidget {
  final String label;
  final _QuizButtonState state;

  const _QuizButton({required this.label, required this.state});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = switch (state) {
      _QuizButtonState.idle    => label == 'O' ? AppColors.info : AppColors.gray200,
      _QuizButtonState.correct => AppColors.success,
      _QuizButtonState.wrong   => AppColors.error,
    };
    final Color textColor = switch (state) {
      _QuizButtonState.idle    => label == 'O' ? Colors.white : AppColors.gray500,
      _QuizButtonState.correct => Colors.white,
      _QuizButtonState.wrong   => Colors.white,
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTypography.highlightBold24.copyWith(
            color: textColor,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}