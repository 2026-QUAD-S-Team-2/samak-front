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
// [ADDED] 공유하기 기능을 위한 board 관련 import
import '../data/repositories/board_repository.dart';
import '../data/models/board_model.dart';

// 분석 결과 데이터 모델
enum TrustLevel { good, bad, normal }

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

// [ADDED] ** 마크다운 강조 문법을 제거하고 순수 텍스트만 반환
String _stripMarkdownBold(String text) {
  return text.replaceAllMapped(
    RegExp(r'\*\*(.+?)\*\*'),
        (match) => match.group(1) ?? '',
  );
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

  Future<void> _loadResult() async {
    try {
      final id = widget.analysisItemId;

      int pollCount = 0;
      while (true) {
        final detail = await AnalysisRepository.instance.getDetail(id);

        if (detail.status == AnalysisStatus.completed) {
          final results = await Future.wait([
            AnalysisRepository.instance.getAiAnalysis(id),
            AnalysisRepository.instance.getCountryWarning(id),
            ReportRepository.instance.getReportHistory(
              companyName: detail.companyName,
              identifierType: detail.contactType,
            ),
          ]);

          final aiResult = results[0] as AiAnalysisResultModel;
          final warning = results[1] as dynamic;
          final historyItems = results[2] as List<ReportHistoryItemModel>;

          final reportHistory = historyItems.isEmpty
              ? '신고 이력이 없습니다.'
              : historyItems.map((h) {
            final date =
                '${h.reportedAt.year}.${h.reportedAt.month.toString().padLeft(2, '0')}';
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
              reportHistoryCount: historyItems.length,
              location: aiResult.location,
            );
            _isLoading = false;
          });
          return;
        } else if (detail.status == AnalysisStatus.failed) {
          setState(() {
            _errorMessage = '분석에 실패했습니다. 다시 시도해 주세요.';
            _isLoading = false;
          });
          return;
        } else if (pollCount >= _maxPollCount) {
          setState(() {
            _errorMessage = '분석에 시간이 오래 걸리고 있습니다. 잠시 후 다시 확인해 주세요.';
            _isLoading = false;
          });
          return;
        }

        pollCount++;
        await Future.delayed(_pollInterval);
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
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

  // [ADDED] 공유하기 다이얼로그 표시 및 게시물 등록 처리
  Future<void> _onShareTap() async {
    if (_resultData == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ShareConfirmDialog(companyName: _resultData!.companyName),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    try {
      await BoardRepository.instance.createPost(
        BoardPostCreateRequest(
          category: 'AI_ANALYSIS',
          title: '${_resultData!.companyName}의 AI 분석 결과',
          // [MODIFIED] ** 마크다운 강조 문법 제거 후 전달
          content: _stripMarkdownBold(_resultData!.companySummary),
          imageNames: [],
          analysisItemId: widget.analysisItemId,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시물에 공유되었습니다.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('공유에 실패했습니다. 다시 시도해 주세요.')),
      );
    }
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
        profileImageUrl: _profileImageUrl,
        onProfileTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfileRouteScreen()),
        ),
      ),
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
            // [수정] 페이지 헤더 + 공유하기 버튼
            Padding(
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
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
                  // [ADDED] 공유하기 버튼
                  GestureDetector(
                    onTap: _onShareTap,
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          AppIcons.share,
                          width: 38,
                          height: 38,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '공유하기',
                          style: AppTypography.small12.copyWith(
                            color: AppColors.gray500,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
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

// [ADDED] 공유 확인 커스텀 다이얼로그 (취소 / 공유하기 2버튼)
class _ShareConfirmDialog extends StatelessWidget {
  final String companyName;

  const _ShareConfirmDialog({required this.companyName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.primary, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '게시판에 공유하기',
              style: AppTypography.largeBold16.copyWith(letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '\'$companyName\'의 AI 분석 결과를\n게시판에 공유하시겠습니까?',
              style: AppTypography.middle14.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.gray300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: AppTypography.large16.copyWith(color: AppColors.gray500),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '공유하기',
                        style: AppTypography.large16.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
      case TrustLevel.good:   return '안전';
      case TrustLevel.bad:    return '위험';
      case TrustLevel.normal: return '주의';
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
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          SvgPicture.asset(iconPath, width: 32, height: 32),
          const SizedBox(width: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
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

// 공통 정보 섹션 카드
class _InfoSection extends StatelessWidget {
  final String title;
  final String content;
  final int?   count;

  const _InfoSection({
    required this.title,
    required this.content,
    this.count,
  });

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
                    color: count! > 0 ? AppColors.error : AppColors.gray300,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '$count건',
                    style: AppTypography.small12.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
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