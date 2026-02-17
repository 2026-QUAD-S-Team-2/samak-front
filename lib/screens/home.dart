import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/app_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

            // 상단 프로필 영역
            _ProfileSection(),

            AppDimensions.verticalGap16,

            // 배너 카드
            Padding(
              padding: AppDimensions.screenEdgePadding,
              child: _BannerCard(),
            ),

            AppDimensions.verticalGap24,

            // 공고 확인 섹션
            _AnnouncementSection(),

            AppDimensions.verticalGap24,

            // 오늘의 퀴즈 섹션
            _QuizSection(),

            AppDimensions.verticalGap24,
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimensions.screenEdgePadding,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.gray900,
          ),
          
          const SizedBox(width: 12,),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('김땡땡님', style: AppTypography.largeBold16,),
                Text(
                  '프로덕트 디자이너',
                  style: AppTypography.small12.copyWith(
                  color: AppColors.gray500
                  ),
                ),
              ],
            )
          ),

          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(0xFFF4F5FF),
              borderRadius: BorderRadius.circular(50)
            ),
            child: Center(
              child: SvgPicture.asset(
                AppIcons.message2,
                width: 20,
                height: 20,
              ),
            ),
          ),

          const SizedBox(width: 8,),

          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(0xFFF4F5FF),
              borderRadius: BorderRadius.circular(50)
            ),
            child: Center(
              child: Icon(
                Icons.notifications,
                color: AppColors.warning,
                size: 20,
              ),
            )
          )
        ],
      )
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

class _QuizSection extends StatelessWidget {
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
                  '오늘의 퀴즈',
                  style: AppTypography.largeBold16.copyWith(
                    letterSpacing: -0.5
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
                    '3',
                    style: AppTypography.smallBold12.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: AppDimensions.screenEdgePadding,
            child: Text(
              '퀴즈를 완료하면 사막 오아시스 포인트가 쌓여요!',
              style: AppTypography.small12.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 퀴즈 카드
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
                    border: Border.all(
                      color: AppColors.gray200,
                      width: 1
                    )
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Q 아이콘
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.bolt,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          '취업 사기가 가장 많이 발생하는 나라는 캄보디아다.',
                          style: AppTypography.middle14.copyWith(
                            letterSpacing: -0.5
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // X / O 버튼
                Row(
                  children: [
                    Expanded(
                      child: _QuizButton(
                        label: 'X',
                        isCorrect: false,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _QuizButton(
                        label: 'O',
                        isCorrect: true,
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
class _QuizButton extends StatelessWidget {
  final String label;
  final bool isCorrect;

  const _QuizButton({
    required this.label,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.info : AppColors.gray200,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTypography.highlightBold24.copyWith(
            color: isCorrect ? Colors.white : AppColors.gray500,
            height: 1.0
          ),
        ),
      ),
    );
  }
}