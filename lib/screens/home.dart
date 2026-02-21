import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/app_icons.dart';
// API 연동
import '../data/repositories/member_repository.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/models/member_model.dart';
import '../data/models/quiz_model.dart';
import '../core/network/api_exception.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 멤버/퀴즈 데이터 상태
  MemberModel? _member;
  TodayQuizModel? _quiz;
  // String? _homeError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 멤버 정보 + 퀴즈 병렬 로드
  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        MemberRepository.instance.getMe(),
        QuizRepository.instance.getTodayQuiz(),
      ]);
      debugPrint('member raw: ${results[0]}');
      setState(() {
        _member = results[0] as MemberModel;
        _quiz   = results[1] as TodayQuizModel;
      });
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
            _ProfileSection(member: _member), // member 전달
            /*
            if (_homeError != null)
              Padding(
                padding: AppDimensions.screenEdgePadding,
                child: Text(
                  _homeError!,
                  style: AppTypography.small12.copyWith(color: AppColors.error),
                ),
              ),
             */
            AppDimensions.verticalGap16,
            Padding(
              padding: AppDimensions.screenEdgePadding,
              child: _BannerCard(),
            ),
            AppDimensions.verticalGap24,
            _AnnouncementSection(),
            AppDimensions.verticalGap24,
            _QuizSection(quiz: _quiz),  // quiz 전달
            AppDimensions.verticalGap24,
          ],
        ),
      ),
    );
  }
}

// member 파라미터 추가
class _ProfileSection extends StatelessWidget {
  final MemberModel? member;

  const _ProfileSection({this.member});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimensions.screenEdgePadding,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            // 프로필 이미지 — 없으면 기본 색상
            backgroundImage: member?.profileImageUrl != null
                ? NetworkImage(member!.profileImageUrl!)
                : null,
            backgroundColor: AppColors.gray900,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member != null ? '${member!.nickname}님' : '불러오는 중...',
                  style: AppTypography.largeBold16,
                ),
                // TODO: 직군 정보는 API 응답에 없으므로 추후 추가 시 연동
              ],
            ),
          ),
          // 메시지·알림 버튼 — 기존 코드 유지
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5FF),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: SvgPicture.asset(AppIcons.message2, width: 20, height: 20),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5FF),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Center(
              child: Icon(Icons.notifications, color: AppColors.warning, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '취업 사기가 걱정되시나요?',
                  style: AppTypography.large16.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5
                  ),
                ),
                const SizedBox(height: 4,),
                Text(
                  '사막 AI 분석이 공고를 검증해 드려요',
                  style: AppTypography.middle13.copyWith(
                    color: AppColors.purple100,
                    letterSpacing: -0.5
                  ),
                )
              ],
            )
          ),
          Container(
            width: 80,
            height: 80,
            child: Image(
              image: AssetImage(AppIcons.banner),
              width: 117,
              height: 85,
            )
          ),
          // 배너 일러스트
        ],
      )
    );
  }
}

class _AnnouncementSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: AppDimensions.screenEdgePadding,
            child: Row(
              children: [
                Text(
                  '공고 확인',
                  style: AppTypography.largeBold16.copyWith(
                    letterSpacing: -0.5
                  ),
                ),
                const SizedBox(width: 8,),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.purple100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '2',
                    style: AppTypography.smallBold12.copyWith(
                      color: AppColors.purple500
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8,),
          Padding(
            padding: AppDimensions.screenEdgePadding,
            child: Text(
              '김땡땡 님이 관심 있는 분야의 공고가 올라왔어요',
              style: AppTypography.small12.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: -0.5
              ),
            ),
          ),
          const SizedBox(height: 16,),
          Padding(
            padding: AppDimensions.screenEdgePadding,
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
          )
        ],
      ),
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

  // O/X 버튼 탭 → 답변 제출
  Future<void> _submitAnswer(bool answer) async {
    if (_isSubmitting || widget.quiz == null) return;
    setState(() => _isSubmitting = true);
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
                Text(
                  '오늘의 퀴즈',
                  style: AppTypography.largeBold16.copyWith(letterSpacing: -0.5),
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

          // const SizedBox(height: 8),
          //
          // Padding(
          //   padding: AppDimensions.screenEdgePadding,
          //   child: Text(
          //     '퀴즈를 완료하면 사막 오아시스 포인트가 쌓여요!',
          //     style: AppTypography.small12.copyWith(color: AppColors.textSecondary),
          //   ),
          // ),

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
                      color: isCorrect
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      explanation,
                      style: AppTypography.small12.copyWith(
                        color: isCorrect ? AppColors.success : AppColors.error,
                        height: 1.5,
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
                          state: isSolved
                              ? (quiz?.answer == false || _answerResult?.correctAnswer == false
                              ? _QuizButtonState.correct
                              : _QuizButtonState.wrong)
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
                          state: isSolved
                              ? (quiz?.answer == true || _answerResult?.correctAnswer == true
                              ? _QuizButtonState.correct
                              : _QuizButtonState.wrong)
                              : _QuizButtonState.idle,
                        ),
                      ),
                    ),
                  ],
                ),
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
      _QuizButtonState.wrong   => AppColors.error.withOpacity(0.3),
    };
    final Color textColor = switch (state) {
      _QuizButtonState.idle    => label == 'O' ? Colors.white : AppColors.gray500,
      _QuizButtonState.correct => Colors.white,
      _QuizButtonState.wrong   => AppColors.gray500,
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