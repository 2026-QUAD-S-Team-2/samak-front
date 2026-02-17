import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/widgets/app_header.dart';
import '../core/design_system/app_icons.dart';

// 분석 결과 데이터 모델
enum TrustLevel { good, bad, normal }

class AnalysisResultData {
  final String companyName;
  final int trustScore; // 0 ~ 100
  final TrustLevel trustLevel;
  final String companySummary;
  final String countryVerification;
  final String reportHistory;

  const AnalysisResultData({
    required this.companyName,
    required this.trustScore,
    required this.trustLevel,
    required this.companySummary,
    required this.countryVerification,
    required this.reportHistory,
  });
}

// 샘플 데이터
const AnalysisResultData _sampleResult = AnalysisResultData(
  companyName: 'OO회사',
  trustScore: 94,
  trustLevel: TrustLevel.good,
  companySummary:
  '\'OO회사\'는 영국 런던에 위치하고 있으며, 구글 지도에서 검색한 회사의 위치와 공고에 표기된 회사의 위치가 일치합니다.\n\n'
      '직원수는 30명 이상으로 보여지며, 지난해 영업이익 __원을 창출한 기록이 있습니다. 지난 2년 간 동행을 확인했을 때 올해도 상승할 추이로 보여집니다.\n\n'
      '블라인드에서의 회사 평점은 4점 이상으로 보여지며, 총 리뷰 50 건 중 긍정 리뷰가 44건 확인되었습니다.',
  countryVerification:
  '2026년 기준 영국의 최저임금은 __유로입니다. \'지원자이름\'님의 현재 경력은 \'1년 미만\'으로 보여지며, 영국의 1년 미만 개발자는 평균 __유로를 받고 있습니다. 공고는 타당한 금액을 연봉으로 제시하고 있습니다.',
  reportHistory: '\'OO회사\'를 신고한 이력은 없으므로 안심하셔도 되어요.',
);

// 공고 분석 결과 화면
class AnalysisResultScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final AnalysisResultData? resultData;

  const AnalysisResultScreen({
    super.key,
    this.onBack,
    this.resultData,
  });

  @override
  Widget build(BuildContext context) {
    final data = resultData ?? _sampleResult;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: '공고 분석 결과',
        showBackButton: true,
        onBack: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── AI 신뢰도 섹션 ──
            _TrustScoreCard(data: data),

            AppDimensions.verticalGap16,

            // ── 그래서 'OO회사'는? 섹션 ──
            _InfoSection(
              title: '그래서 \'${data.companyName}\'는?',
              content: data.companySummary,
            ),

            AppDimensions.verticalGap16,

            // ── 국가 기반 검증 섹션 ──
            _InfoSection(
              title: '국가 기반 검증',
              content: data.countryVerification,
            ),

            AppDimensions.verticalGap16,

            // ── 신고 이력 섹션 ──
            _InfoSection(
              title: '신고 이력',
              content: data.reportHistory,
            ),

            SizedBox(height: AppDimensions.navigatorBarHeight),
          ],
        ),
      ),
    );
  }
}

// AI 신뢰도 카드
class _TrustScoreCard extends StatefulWidget {
  final AnalysisResultData data;

  const _TrustScoreCard({required this.data});

  @override
  State<_TrustScoreCard> createState() => _TrustScoreCardState();
}

class _TrustScoreCardState extends State<_TrustScoreCard> {
  bool _showTooltip = false;

  Color get _levelColor {
    switch (widget.data.trustLevel) {
      case TrustLevel.good:
        return AppColors.success;
      case TrustLevel.bad:
        return AppColors.error;
      case TrustLevel.normal:
        return AppColors.warning;
    }
  }

  String get _levelLabel {
    switch (widget.data.trustLevel) {
      case TrustLevel.good:
        return 'Good';
      case TrustLevel.bad:
        return 'Bad';
      case TrustLevel.normal:
        return 'Normal';
    }
  }

  String get _scoreEmoji {
    if (widget.data.trustScore >= 70) return '😊';
    if (widget.data.trustScore >= 40) return '😐';
    return '😟';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 헤더 행: AI 신뢰도 + 레벨 뱃지 + 물음표 아이콘 + [툴팁] ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  'AI 신뢰도',
                  style: AppTypography.largeBold16.copyWith(letterSpacing: -0.5),
                ),
              ),
              const SizedBox(width: 8),

              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _levelColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    _levelLabel,
                    style: AppTypography.smallBold12.copyWith(
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              GestureDetector(
                onTap: () => setState(() => _showTooltip = !_showTooltip),
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: SvgPicture.asset(
                    AppIcons.questionCircle,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      _showTooltip ? AppColors.gray900 : AppColors.gray500,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),

              if (_showTooltip) ...[
                const SizedBox(width: 4),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.purple050,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '신뢰도는 AI가 분석한 결과를 기반으로 제공됩니다. 보다 안전한 판단을 위해 재차 확인을 권장드립니다.',
                      style: AppTypography.small8.copyWith(
                        color: AppColors.gray900,
                        height: 1.0,
                      ),
                      softWrap: true,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          Text(
            '\'${widget.data.companyName}\'는 ${widget.data.trustScore}% 신뢰할 수 있습니다.',
            style: AppTypography.middle14.copyWith(
              letterSpacing: -0.3,
              color: AppColors.gray900,
            ),
          ),

          const SizedBox(height: 16),

          _TrustProgressBar(
            score: widget.data.trustScore,
            emoji: _scoreEmoji,
            barColor: _levelColor,
          ),
        ],
      ),
    );
  }
}

// 신뢰도 프로그레스 바
class _TrustProgressBar extends StatelessWidget {
  final int score;
  final String emoji;
  final Color barColor;

  const _TrustProgressBar({
    required this.score,
    required this.emoji,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = score.clamp(0, 100) / 100.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          // 이모지 아이콘
          Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),

          const SizedBox(width: 12),

          // 프로그레스 바
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // 배경 트랙
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    Container(
                      height: 4,
                      width: constraints.maxWidth * ratio,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 공통 정보 섹션 카드 (그래서 ~, 국가 기반 검증, 신고 이력)
class _InfoSection extends StatelessWidget {
  final String title;
  final String content;

  const _InfoSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.largeBold16.copyWith(letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTypography.middle14.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}