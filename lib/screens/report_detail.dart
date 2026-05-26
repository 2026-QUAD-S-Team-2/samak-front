// [ADDED] 피해 사례 상세 조회 화면
// GET /api/v1/reports/detail?companyName={companyName}
// [MODIFIED] StatelessWidget → StatefulWidget, 더미 데이터 제거, 실제 API 연동
import 'package:flutter/material.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/widgets/app_header.dart';
import '../core/design_system/widgets/app_dialog.dart';
import '../core/network/api_exception.dart';
import '../data/models/report_model.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/member_repository.dart';
import '../screens/profile_screen.dart';

class ReportDetailScreen extends StatefulWidget {
  final String companyName;

  const ReportDetailScreen({super.key, required this.companyName});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  // [ADDED] API 상태 변수
  bool _isLoading = true;
  ReportDetailModel? _detail;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadDetail();
    _loadProfile();
  }

  // [ADDED] API 호출 메서드
  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    try {
      final detail = await ReportRepository.instance.getReportDetail(
        companyName: widget.companyName,
      );
      setState(() => _detail = detail);
    } on ApiException catch (e) {
      if (mounted) {
        AppDialog.show(
          context,
          title: '조회 실패',
          message: e.message,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // [MODIFIED] 프로필 이미지 로드
  Future<void> _loadProfile() async {
    try {
      final member = await MemberRepository.instance.getMe();
      if (mounted) setState(() => _profileImageUrl = member.profileImageUrl);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(
        title: '피해 사례',
        showBackButton: true,
        onBack: () => Navigator.of(context).maybePop(),
        profileImageUrl: _profileImageUrl,
        onProfileTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
      ),
      // [MODIFIED] 더미 데이터 → _isLoading / _detail 상태 기반 분기 렌더링
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : _detail == null
          ? const SizedBox.shrink()
          : ListView(
        padding: const EdgeInsets.only(top: 0, bottom: 24),
        children: [
          // ── 회사명 + 신고 건수 + 최근 신고일 ──
          _HeaderSection(detail: _detail!),
          const SizedBox(height: 36),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
            child: Column(
              children: [
                // ── 연락 수단 ──
                _SectionCard(
                  title: '연락 수단',
                  child: _ContactMethodsContent(methods: _detail!.contactMethods),
                ),
                const SizedBox(height: 36),

                // ── 피해 내용 ──
                _SectionCard(
                  title: '피해 내용',
                  child: _DamagesContent(damages: _detail!.damages),
                ),
                const SizedBox(height: 36),

                // ── 증거 자료 ──
                _SectionCard(
                  title: '증거 자료',
                  child: _EvidenceImagesContent(urls: _detail!.evidenceImageUrls),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 상단 헤더: 회사명 / 신고 건수 / 최근 신고일 ──
class _HeaderSection extends StatelessWidget {
  final ReportDetailModel detail;

  const _HeaderSection({required this.detail});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${detail.latestReportedAt.year}.${detail.latestReportedAt.month.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      color: AppColors.gray100,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPadding, 24, AppDimensions.screenPadding, 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.companyName,
            style: AppTypography.large20.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '신고 ',
                style: AppTypography.middleBold15.copyWith(color: AppColors.gray900, fontWeight: FontWeight.w700),
              ),
              Text(
                '${detail.reportCount}건',
                style: AppTypography.middleBold15.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '최근 신고 $dateStr',
                style: AppTypography.small12.copyWith(color: AppColors.gray500),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ── 섹션 공통 카드 래퍼 ──
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.middle14.copyWith(letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ── 연락 수단 콘텐츠 ──
class _ContactMethodsContent extends StatelessWidget {
  final List<ContactMethodModel> methods;

  const _ContactMethodsContent({required this.methods});

  @override
  Widget build(BuildContext context) {
    if (methods.isEmpty) {
      return Text(
        '등록된 연락 수단이 없습니다.',
        style: AppTypography.middle14.copyWith(color: AppColors.gray500),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: methods
          .expand((m) => m.values.map((v) => _ContactChip(type: m.type, value: v)))
          .toList(),
    );
  }
}

// ── 연락 수단 칩 ──
class _ContactChip extends StatelessWidget {
  final String type;
  final String value;

  const _ContactChip({required this.type, required this.value});

  String get _label {
    switch (type.toUpperCase()) {
      case 'TELEGRAM':
        return '텔레그램';
      case 'EMAIL':
        return '이메일';
      case 'PHONE':
        return '전화';
      case 'KAKAO':
        return '카카오톡';
      case 'MESSAGE':
        return '메시지';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFEBF1FF),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        _label,
        style: AppTypography.small12.copyWith(
          color: AppColors.info,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// ── 피해 내용 콘텐츠 ──
class _DamagesContent extends StatelessWidget {
  final List<DamageModel> damages;

  const _DamagesContent({required this.damages});

  @override
  Widget build(BuildContext context) {
    if (damages.isEmpty) {
      return Text(
        '등록된 피해 내용이 없습니다.',
        style: AppTypography.middle14.copyWith(color: AppColors.gray500),
      );
    }

    return Column(
      children: damages
          .expand((d) => [_DamageItem(damage: d), const SizedBox(height: 6)])
          .toList()
        ..removeLast(),
    );
  }
}

// ── 피해 내용 단일 아이템 ──
class _DamageItem extends StatelessWidget {
  final DamageModel damage;

  const _DamageItem({required this.damage});

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                damage.reporterName,
                style: AppTypography.smallBold12.copyWith(color: AppColors.gray900),
              ),
              Text(
                _formatDate(damage.reportedAt),
                style: AppTypography.small12.copyWith(color: AppColors.gray500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            damage.reason,
            style: AppTypography.middle14.copyWith(
              color: AppColors.gray900,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 증거 자료 콘텐츠 ──
class _EvidenceImagesContent extends StatelessWidget {
  final List<String> urls;

  const _EvidenceImagesContent({required this.urls});

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return Text(
        '등록된 증거 자료가 없습니다.',
        style: AppTypography.middle14.copyWith(color: AppColors.gray500),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => _showImageDialog(context, urls, index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              urls[index],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 100,
                color: AppColors.gray200,
                child: const Icon(Icons.broken_image, color: AppColors.gray500),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // [ADDED] 이미지 탭 시 전체 화면 확대 다이얼로그
  void _showImageDialog(BuildContext context, List<String> urls, int initialIndex) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: urls.length,
              itemBuilder: (_, i) => InteractiveViewer(
                child: Image.network(
                  urls[i],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white, size: 48),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}