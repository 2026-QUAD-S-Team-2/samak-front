import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/widgets/app_header.dart';
import '../core/design_system/app_icons.dart';
import '../data/repositories/member_repository.dart';
import '../screens/profile_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// API 연동
import '../data/repositories/analysis_repository.dart';
import '../data/models/ai_analysis_result_model.dart';
import '../data/models/analysis_item_list_model.dart';
import '../core/network/api_exception.dart';
import '../data/repositories/report_repository.dart';
import '../data/models/report_model.dart';

// 분석 결과 데이터 모델
enum TrustLevel { good, bad, normal }

// 수정 후
class AnalysisResultData {
  final String companyName;
  final int trustScore;
  final TrustLevel trustLevel;
  final String companySummary;
  final String countryVerification;
  final String reportHistory;
  final int reportHistoryCount;
  final AiAnalysisLocationModel? location;

  const AnalysisResultData({
    required this.companyName,
    required this.trustScore,
    required this.trustLevel,
    required this.companySummary,
    required this.countryVerification,
    required this.reportHistory,
    required this.reportHistoryCount,
    this.location,
  });
}

Color trustLevelColor(TrustLevel level) {
  switch (level) {
    case TrustLevel.good:   return AppColors.success;
    case TrustLevel.normal: return AppColors.warning;
    case TrustLevel.bad:    return AppColors.error;
  }
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
  static const int _maxPollCount = 30;
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
          // COMPLETED → AI 분석 결과 + 국가 경고 + 신고 이력 조회
          final results = await Future.wait([
            AnalysisRepository.instance.getAiAnalysis(id),
            AnalysisRepository.instance.getCountryWarning(id),
            // [ADDED] 신고 이력 조회: 회사명 + 연락 수단 유형으로 검색
            ReportRepository.instance.getReportHistory(
              companyName: detail.companyName,
              identifierType: detail.contactType,
            ),
          ]);

          final aiResult = results[0] as AiAnalysisResultModel;
          final warning = results[1] as dynamic;
          // [ADDED] 신고 이력 항목 추출
          final historyItems = results[2] as List<ReportHistoryItemModel>;

          // [ADDED] 신고 이력 문자열 포맷: 항목별 한 줄, 없으면 안내 문구
          final reportHistory = historyItems.isEmpty
              ? '신고 이력이 없습니다.'
              : historyItems.map((h) {
            final date =
                '${h.reportedAt.year}.${h.reportedAt.month.toString().padLeft(
                2, '0')}';
            return '• ${h.identifierType}: ${h.identifierValue}  ($date)';
          }).join('\n');

          final trustLevel = switch (100 - aiResult.riskScore) {
            >= 70 => TrustLevel.good,
            >= 40 => TrustLevel.normal,
            _ => TrustLevel.bad,
          };

          setState(() {
            _resultData = AnalysisResultData(
              companyName: detail.companyName as String,
              trustScore: 100 - aiResult.riskScore,
              trustLevel: trustLevel,
              companySummary: aiResult.message,
              countryVerification: warning.warningMessage as String,
              reportHistory: reportHistory,
              // [ADDED]
              reportHistoryCount: historyItems.length, // [ADDED]
              location: aiResult.location,
            );
            _isLoading = false;
          });
          return;
        }
        else if (detail.status == AnalysisStatus.failed) {
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
        backgroundColor: _resultData != null
            ? trustLevelColor(_resultData!.trustLevel).withOpacity(0.05)
            : AppColors.background,
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
            if (_resultData!.location != null)
                _LocationMapSection(location: _resultData!.location!),
            _InfoSection(
              title: '국가 기반 검증',
              content: _resultData!.countryVerification,
            ),
            AppDimensions.verticalGap16,
            _InfoSection(
              title: '신고 이력',
              content: _resultData!.reportHistory,
              count: _resultData!.reportHistoryCount,
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

  Color get _levelColor => trustLevelColor(widget.data.trustLevel);

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _levelColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        _levelLabel,
                        style: AppTypography.middleBold15.copyWith(
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6,),

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

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  'AI 신뢰도 ${widget.data.trustScore}%',
                  style: AppTypography.large20.copyWith(letterSpacing: -0.5, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
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
// 수정 후
class _InfoSection extends StatelessWidget {
  final String  title;
  final String  content;
  final int?    count; // [ADDED] 선택적 건수 뱃지 (신고 이력 섹션에서만 사용)

  const _InfoSection({
    required this.title,
    required this.content,
    this.count, // [ADDED]
  });

  // [추가] ** 감싸인 텍스트를 파싱하여 TextSpan 리스트로 변환
  List<TextSpan> _buildStyledSpans(
      String text, {
        required TextStyle normalStyle,
        required TextStyle boldStyle,
      }) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start), style: normalStyle));
      }
      spans.add(TextSpan(text: match.group(1), style: boldStyle));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: normalStyle));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // [MODIFIED] count가 있을 때 제목 옆에 건수 뱃지 표시
          Row(
            children: [
              Text(
                title,
                style: AppTypography.largeBold16.copyWith(letterSpacing: -0.5),
              ),
              if (count != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:        count! > 0 ? AppColors.error : AppColors.gray300,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '$count건',
                    style: AppTypography.small12.copyWith(
                      color:      Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // [수정] ** 패턴 파싱하여 중요 텍스트 강조 표시
          RichText(
            text: TextSpan(
              children: _buildStyledSpans(
                content,
                normalStyle: AppTypography.middle14.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                  letterSpacing: -0.3,
                ),
                boldStyle: AppTypography.middle14.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w800,
                  height: 1.6,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// [ADDED] 회사 위치 지도 섹션
class _LocationMapSection extends StatefulWidget {
  final AiAnalysisLocationModel location;

  const _LocationMapSection({required this.location});

  @override
  State<_LocationMapSection> createState() => _LocationMapSectionState();
}

class _LocationMapSectionState extends State<_LocationMapSection> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '위치',
            style: AppTypography.largeBold16.copyWith(letterSpacing: -0.5),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.location.lat, widget.location.lng),
                      zoom: widget.location.zoom,
                    ),
                    onMapCreated: (controller) => _mapController = controller,
                    markers: {
                      Marker(
                        markerId: const MarkerId('company'),
                        position: LatLng(widget.location.lat, widget.location.lng),
                        infoWindow: InfoWindow(title: widget.location.rawText),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  color: Colors.white,
                  child: Text(
                    widget.location.rawText,
                    style: AppTypography.middle14.copyWith(
                      color: AppColors.gray500,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}