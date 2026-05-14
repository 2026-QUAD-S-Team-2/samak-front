import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/widgets/app_header.dart';
import '../core/design_system/app_icons.dart';
import '../data/repositories/member_repository.dart';
import '../screens/profile_screen.dart';
// API 연동
import '../data/repositories/analysis_repository.dart';
import '../data/models/ai_analysis_result_model.dart';
import '../data/models/analysis_item_list_model.dart';
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
  static const Duration _pollInterval = Duration(seconds: 3);
  static const int _maxPollCount = 20; // 최대 60초 대기
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadResult();
    _loadProfile();
  }

  // 3개 API 병렬 호출 후 AnalysisResultData로 변환
  Future<void> _loadResult() async {
    try {
      final id = widget.analysisItemId;
      // debugPrint('[AnalysisResult] 로드 시작 - analysisItemId: $id');

      // [ADDED] COMPLETED 상태가 될 때까지 폴링
      int pollCount = 0;
      while (true) {
        final detail = await AnalysisRepository.instance.getDetail(id);
        // debugPrint('[AnalysisResult] status: ${detail.status}, pollCount: $pollCount');

        if (detail.status == AnalysisStatus.completed) {
          // COMPLETED → AI 분석 결과 + 국가 경고 조회
          final results = await Future.wait([
            AnalysisRepository.instance.getAiAnalysis(id),
            AnalysisRepository.instance.getCountryWarning(id),
          ]);

          final aiResult = results[0] as AiAnalysisResultModel;
          final warning  = results[1] as dynamic;

          // debugPrint('[AnalysisResult] aiResult: riskScore=${aiResult.riskScore}, riskLevel=${aiResult.riskLevel}');
          // debugPrint('[AnalysisResult] warning: ${warning.warningMessage}');

          // [수정] riskLevel 문자열 대신 riskScore 숫자 기준으로 trustLevel 결정
          final trustLevel = switch (100 - aiResult.riskScore) {
            >= 70 => TrustLevel.good,
            >= 40 => TrustLevel.normal,
            _     => TrustLevel.bad,
          };

          setState(() {
            _resultData = AnalysisResultData(
              companyName:         detail.companyName as String,
              trustScore:          100 - aiResult.riskScore,
              trustLevel:          trustLevel,
              companySummary:      aiResult.message,
              countryVerification: warning.warningMessage as String,
              reportHistory:       '신고 이력이 없습니다.',
            );
            _isLoading = false;
          });
          return;

        } else if (detail.status == AnalysisStatus.failed) {
          // [ADDED] 분석 실패 처리
          // debugPrint('[AnalysisResult] 분석 실패');
          setState(() {
            _errorMessage = '분석에 실패했습니다. 다시 시도해 주세요.';
            _isLoading = false;
          });
          return;

        } else if (pollCount >= _maxPollCount) {
          // [ADDED] 최대 대기 시간 초과
          // debugPrint('[AnalysisResult] 폴링 타임아웃');
          setState(() {
            _errorMessage = '분석에 시간이 오래 걸리고 있습니다. 잠시 후 다시 확인해 주세요.';
            _isLoading = false;
          });
          return;
        }

        // [ADDED] PENDING/PROCESSING → 대기 후 재시도
        pollCount++;
        await Future.delayed(_pollInterval);
      }

    } on ApiException catch (e) {
      // debugPrint('[AnalysisResult] ApiException: ${e.message}');
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      // debugPrint('[AnalysisResult] 예상치 못한 에러: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      final member = await MemberRepository.instance.getMe();
      if (mounted) setState(() => _profileImageUrl = member.profileImageUrl);
    } catch (_) {}
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: '공고 분석 결과',
        showBackButton: true,
        onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
        profileImageUrl: _profileImageUrl, // [ADDED]
        onProfileTap: () => Navigator.of(context).push( // [ADDED]
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
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
            // [수정] 페이지 헤더 추가
            Padding(
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '공고 분석 결과',
                    style: AppTypography.large20.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '사막AI가 분석한 공고의 신뢰도입니다.',
                    style: AppTypography.small12.copyWith(
                      color: AppColors.gray500,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            AppDimensions.verticalGap16,
            _TrustScoreCard(data: _resultData!),
            AppDimensions.verticalGap16,
            _InfoSection(
              title: '\'${_resultData!.companyName}\'는?',
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
      case TrustLevel.good:   return '안전'; // [수정] Good → 안전
      case TrustLevel.bad:    return '위험'; // [수정] Bad → 위험
      case TrustLevel.normal: return '주의'; // [수정] Normal → 주의
    }
  }

  String get _scoreIconPath {
    switch (widget.data.trustLevel) {
      case TrustLevel.good:   return AppIcons.goodFace;
      case TrustLevel.normal: return AppIcons.normalFace;
      case TrustLevel.bad:    return AppIcons.badFace;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
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
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(12),
      // ),
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