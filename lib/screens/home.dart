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
      backgroundColor: AppColors.gray100,
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
              color: AppColors.highlight,
              borderRadius: BorderRadius.circular(8)
            ),
            child: Center(
              child: SvgPicture.asset(
                AppIcons.chatDots,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),

          const SizedBox(width: 8,),

          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8)
            ),
            child: Center(
              child: SvgPicture.asset(
                AppIcons.bell,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              )
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
        borderRadius: BorderRadius.circular(16),
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
                    fontWeight: FontWeight.w700
                  ),
                ),
                const SizedBox(height: 4,),
                Text(
                  '사막 AI 분석이 공고를 검증해 드려요',
                  style: AppTypography.middle14.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                )
              ],
            )
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.flight,
              size: 40,
              color: Colors.white.withOpacity(0.5),
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppDimensions.screenEdgePadding,
          child: Row(
            children: [
              Text(
                '공고 확인',
                style: AppTypography.largeBold16,
              ),
              const SizedBox(width: 8,),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '2',
                  style: AppTypography.smallBold12.copyWith(
                    color: Colors.white
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
            style: AppTypography.middle14.copyWith(
              color: AppColors.gray500
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
                companyName: '\'OO회사A\' 공고',
                dateRange: '2.08 - 2.26',
                memberCount: 3,
                hasMoreMembers: false,
                isActive: false,
              ),
            ],
          ),
        )
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ]
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
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.gray300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4,),
                  Text(
                    dateRange,
                    style: AppTypography.small12.copyWith(
                      color: AppColors.gray500,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8,),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '분석하기',
                  style: AppTypography.small12.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppDimensions.screenEdgePadding,
          child: Row(
            children: [
              Text(
                '오늘의 퀴즈',
                style: AppTypography.largeBold16,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '3',
                  style: AppTypography.smallBold12.copyWith(
                    color: Colors.white,
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
            '퀴즈를 완료하면 사막 OO시스 포인트가 쌓여요!',
            style: AppTypography.middle14.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 퀴즈 카드
        Padding(
          padding: AppDimensions.screenEdgePadding,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 퀴즈 질문
                Row(
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
                        child: Text(
                          'Q',
                          style: AppTypography.smallBold12.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        '취업 사기가 가장 많이 발생하는 나라는 캄보디아다.',
                        style: AppTypography.middle14,
                      ),
                    ),
                  ],
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
        ),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.info : AppColors.gray200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTypography.large16.copyWith(
            color: isCorrect ? Colors.white : AppColors.gray500,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}