import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/widgets/app_header.dart';
import '../core/design_system/app_icons.dart';
import '../screens/analysis_result.dart';

class AnalysisRegisterScreen extends StatefulWidget {
  final VoidCallback? onBack;

  final VoidCallback? onConfirmResult;

  const AnalysisRegisterScreen({
    super.key,
    this.onBack,
    this.onConfirmResult,
  });

  @override
  State<AnalysisRegisterScreen> createState() =>
      _AnalysisRegisterScreenState();
}

class _AnalysisRegisterScreenState
    extends State<AnalysisRegisterScreen> {
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _etcController = TextEditingController();

  String? _selectedCountry;
  String? _selectedCity;
  String? _selectedChannel;

  // TODO: 국가/지역 목록 (추후 서버 데이터로 교체 필요)
  final List<String> _countries = ['한국', '중국', '미국', '일본', '기타'];

  // TODO: 지역 목록 (추후 서버 데이터로 교체 필요)
  final List<String> _cities = ['서울특별시', '부산광역시', '인천광역시', '대구광역시'];

  // TODO: 채널 목록 (추후 서버 데이터로 교체 필요)
  final List<String> _channels = ['원티드', '사람인', '잡코리아', '링크드인', '기타'];

  @override
  void dispose() {
    _linkController.dispose();
    _companyController.dispose();
    _salaryController.dispose();
    _etcController.dispose();
    super.dispose();
  }

  // 등록 완료 바텀 시트
  void _showCompletionBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _CompletionBottomSheet(
        onConfirm: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AnalysisResultScreen(
                onBack: () => Navigator.of(context).pop(),
                // TODO: 등록된 공고 데이터 → AnalysisResultData 변환 로직 연결 필요 (서버 응답 연동 시)
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: '공고 분석 등록',
        showBackButton: true,
        onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 이미지 섹션 ──
              const _SectionLabel(label: '이미지', isRequired: true),
              const SizedBox(height: 4),
              Text(
                'ex) 채팅 내용, 공고 내용 캡쳐본',
                style: AppTypography.small12.copyWith(
                  color: AppColors.gray500,
                ),
              ),
              const SizedBox(height: 12),

              // TODO: 가로 스크롤 이미지 슬롯 (추후 image_picker 패키지 연결 필요)
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, __) => const _ImageSlot(),
                ),
              ),

              const SizedBox(height: 24),

              // ── 채용 공고 링크 ──
              const _SectionLabel(label: '채용 공고 링크'),
              const SizedBox(height: 8),
              _OutlinedTextField(
                controller: _linkController,
                hintText: 'ex) www.wanted.com',
              ),

              const SizedBox(height: 20),

              // ── 회사 ──
              const _SectionLabel(label: '회사', isRequired: true),
              const SizedBox(height: 8),
              _OutlinedTextField(
                controller: _companyController,
                hintText: '회사 이름을 입력해 주세요',
              ),

              const SizedBox(height: 20),

              // ── 제안 임금 ──
              const _SectionLabel(label: '제안 임금', isRequired: false),
              const SizedBox(height: 8),
              _OutlinedTextField(
                controller: _salaryController,
                hintText: '시급 기준으로 통화와 함께 입력해 주세요',
                helperText: '예: KRW 12000/h, USD 25/h',
              ),

              const SizedBox(height: 20),

              // ── 국가 드롭다운 ──
              // TODO: 국가 이름과 국가 코드 (ISO 3166-1 alpha-2)와 매칭하여 백엔드로 보내기
              const _SectionLabel(label: '국가', isRequired: true),
              const SizedBox(height: 8),
              _OutlinedDropdown(
                value: _selectedCountry,
                hintText: '국가를 선택해 주세요',
                items: _countries,
                onChanged: (v) => setState(() => _selectedCountry = v),
              ),

              const SizedBox(height: 20),

              // ── 지역 드롭다운 ──
              const _SectionLabel(label: '지역', isRequired: true),
              const SizedBox(height: 8),
              _OutlinedDropdown(
                value: _selectedCity,
                hintText: '지역을 선택해 주세요',
                items: _cities,
                onChanged: (v) => setState(() => _selectedCity = v),
              ),

              const SizedBox(height: 20),

              // ── 채널 드롭다운 ──
              const _SectionLabel(label: '채널', isRequired: true),
              const SizedBox(height: 8),
              _OutlinedDropdown(
                value: _selectedChannel,
                hintText: '채널을 선택해 주세요',
                items: _channels,
                onChanged: (v) => setState(() => _selectedChannel = v),
              ),

              const SizedBox(height: 20),

              // ── 기타 ──
              const _SectionLabel(label: '기타'),
              const SizedBox(height: 8),
              _OutlinedTextField(
                controller: _etcController,
                hintText: '기타 사항을 자유롭게 기재해주세요.',
                maxLines: 5,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),

      // ── 하단 등록 버튼 ──
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding, vertical: 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _showCompletionBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 0,
              ),
              child: Text(
                '공고 등록하기',
                style: AppTypography.large16.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 섹션 레이블 ──
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const _SectionLabel({
    required this.label,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTypography.middleBold15),
        if (isRequired)
          Text(
            ' *',
            style: AppTypography.middleBold15.copyWith(color: AppColors.error),
          ),
      ],
    );
  }
}

// ── 이미지 슬롯 ──
// TODO: 이미지 첨부 슬롯. onTap에 image_picker 패키지 연결 필요.
class _ImageSlot extends StatelessWidget {
  const _ImageSlot();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 이미지 피커 연결 필요
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.gray200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(
            Icons.add_photo_alternate_outlined,
            color: AppColors.gray500,
            size: 28,
          ),
        ),
      ),
    );
  }
}

// ── 외곽선 텍스트 필드 ──
class _OutlinedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? helperText;
  final int maxLines;

  const _OutlinedTextField({
    required this.controller,
    required this.hintText,
    this.helperText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray100,
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          )
        ]
      ),
      child: TextField(
        // TODO: 그림자 추가
        controller: controller,
        maxLines: maxLines,
        style: AppTypography.middle14,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.middle14.copyWith(color: AppColors.gray500),
          helperText: helperText,
          helperStyle: AppTypography.small12.copyWith(color: AppColors.gray500),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.gray300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.gray900, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

// ── 외곽선 드롭다운 ──
class _OutlinedDropdown extends StatelessWidget {
  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _OutlinedDropdown({
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(
        hintText,
        style: AppTypography.middle14.copyWith(color: AppColors.gray500),
      ),
      icon: SvgPicture.asset(
        AppIcons.arrowDown,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(AppColors.gray500, BlendMode.srcIn),
      ),
      style: AppTypography.middle14.copyWith(color: AppColors.gray900),
      decoration: InputDecoration(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray900, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ── 등록 완료 바텀 시트 ──
class _CompletionBottomSheet extends StatelessWidget {
  final VoidCallback onConfirm;

  const _CompletionBottomSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 70),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '공고 등록이 완료되었어요.',
            style: AppTypography.largeBold16.copyWith(
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '사막이 분석한 공고의 신뢰도를 지금 확인해보세요.',
            style: AppTypography.middle14.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              // TODO: onConfirmResult 콜백으로 분석 결과 화면 연결 필요
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 0,
              ),
              child: Text(
                '분석 결과 확인하기',
                style: AppTypography.large16.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}