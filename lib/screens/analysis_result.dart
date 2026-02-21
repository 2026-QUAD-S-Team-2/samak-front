import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/widgets/app_header.dart';
import '../core/design_system/app_icons.dart';
// API 연동
import '../data/repositories/analysis_repository.dart';
import '../data/models/ai_analysis_result_model.dart';
import '../core/network/api_exception.dart';

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

// 공고 분석 결과 화면
class AnalysisResultScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final int analysisItemId;

  const AnalysisResultScreen({
    super.key,
    this.onBack,
    required this.analysisItemId,
  });

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  // 로딩 및 데이터 상태
  bool _isLoading = true;
  String? _errorMessage;
  AnalysisResultData? _resultData;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  // 3개 API 병렬 호출 후 AnalysisResultData로 변환
  Future<void> _loadResult() async {
    try {
      final id = widget.analysisItemId;
      final results = await Future.wait([
        AnalysisRepository.instance.getDetail(id),
        AnalysisRepository.instance.getAiAnalysis(id),
        AnalysisRepository.instance.getCountryWarning(id),
      ]);

      final detail    = results[0] as dynamic; // AnalysisItemDetailModel
      final aiResult  = results[1] as AiAnalysisResultModel;
      final warning   = results[2] as dynamic; // CountryWarningModel

      // riskLevel → TrustLevel 변환
      final trustLevel = switch (aiResult.riskLevel.toUpperCase()) {
        'LOW'    => TrustLevel.good,
        'MEDIUM' => TrustLevel.normal,
        _        => TrustLevel.bad,   // HIGH
      };

      setState(() {
        _resultData = AnalysisResultData(
          companyName:         detail.companyName as String,
          trustScore:          100- aiResult.riskScore,
          trustLevel:          trustLevel,
          companySummary:      aiResult.message,
          countryVerification: warning.warningMessage as String,
          reportHistory:       '신고 이력 데이터를 불러왔습니다.',
          // TODO: 신고 이력 API 연동 시 교체
        );
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: '공고 분석 결과',
        showBackButton: true,
        onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
      ),
      // [ADDED] 로딩 / 에러 / 성공 상태 분기
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
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TrustScoreCard(data: _resultData!),
            AppDimensions.verticalGap16,
            _InfoSection(
              title: '그래서 \'${_resultData!.companyName}\'는?',
              content: _resultData!.companySummary,
            ),
            AppDimensions.verticalGap16,
            _InfoSection(
              title: '국가 기반 검증',
              content: _resultData!.countryVerification,
            ),
            AppDimensions.verticalGap16,
            _InfoSection(
              title: '신고 이력',
              content: _resultData!.reportHistory,
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

  String get _scoreIconPath {
    if (widget.data.trustScore >= 70) return AppIcons.goodFace;
    if (widget.data.trustScore >= 40) return AppIcons.normalFace;
    return AppIcons.badFace;
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
                    style: AppTypography.small12.copyWith(
                      color: Colors.black,
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
                      '신뢰도는 AI가 분석한 결과를 기반으로 제공되므로 재차 확인을 권장드립니다.',
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
            iconPath: _scoreIconPath,
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
  final String iconPath;
  final Color barColor;

  const _TrustProgressBar({
    required this.score,
    required this.iconPath,
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
          SvgPicture.asset(
            iconPath,
            width: 32,
            height: 32,
          ),

          const SizedBox(width: 12),

          // 프로그래스 바
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
                    )
                  ],
                );
              }
            )
          )
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