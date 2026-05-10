// [ADDED] 피해 사례 등록 화면
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/widgets/app_header.dart';
import '../core/design_system/widgets/app_dropdown.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/image_repository.dart';
import '../data/models/report_model.dart';
import '../core/network/api_exception.dart';
import '../core/design_system/widgets/app_dialog.dart';
import '../data/repositories/member_repository.dart';
import '../screens/profile_screen.dart';

class ReportRegisterScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ReportRegisterScreen({super.key, this.onBack});

  @override
  State<ReportRegisterScreen> createState() => _ReportRegisterScreenState();
}

class _ReportRegisterScreenState extends State<ReportRegisterScreen> {
  final TextEditingController _companyController      = TextEditingController();
  final TextEditingController _contactValueController = TextEditingController();
  final TextEditingController _reasonController       = TextEditingController();
  final TextEditingController _evidenceController     = TextEditingController();

  String? _selectedContactType;
  bool    _isSubmitting = false;
  String? _profileImageUrl;

  final ImagePicker    _imagePicker  = ImagePicker();
  final List<XFile>    _pickedImages = [];

  // 연락 수단 한국어 → API 값 매핑 (analysis_register.dart의 _channelContactTypeMap과 동일한 패턴)
  static const Map<String, String> _contactTypeMap = {
    '이메일':   'EMAIL',
    '텔레그램': 'TELEGRAM',
    '전화':     'PHONE',
  };
  final List<String> _contactTypes = _contactTypeMap.keys.toList();

  // 연락 수단별 힌트 텍스트
  String get _contactValueHint {
    switch (_selectedContactType) {
      case '이메일':   return 'ex) example@email.com';
      case '텔레그램': return 'ex) @telegram_id';
      case '전화':     return 'ex) 010-1234-5678';
      default:         return '아이디 혹은 전화번호를 입력해 주세요';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _companyController.dispose();
    _contactValueController.dispose();
    _reasonController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final member = await MemberRepository.instance.getMe();
      if (mounted) setState(() => _profileImageUrl = member.profileImageUrl);
    } catch (_) {}
  }

  // 이미지 추가 (최대 4장, analysis_register.dart와 동일한 패턴)
  Future<void> _pickImage() async {
    if (_pickedImages.length >= 4) return;
    final XFile? image = await _imagePicker.pickImage(
      source:       ImageSource.gallery,
      imageQuality: 30,
      maxWidth:     800,
      maxHeight:    800,
    );
    if (image != null) setState(() => _pickedImages.add(image));
  }

  void _removeImage(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  // 등록 실행 — 유효성 검사 → 이미지 업로드(선택) → 신고 등록
  Future<void> _submit() async {
    if (_companyController.text.trim().isEmpty ||
        _selectedContactType == null ||
        _contactValueController.text.trim().isEmpty ||
        _reasonController.text.trim().isEmpty ||
        _evidenceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 항목을 모두 입력해 주세요.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // 이미지가 있을 때만 업로드 (증거 자료 이미지는 선택)
    List<String> imageNames = [];
    if (_pickedImages.isNotEmpty) {
      try {
        if (_pickedImages.length == 1) {
          imageNames = [
            await ImageRepository.instance.uploadSingle(_pickedImages.first),
          ];
        } else {
          imageNames =
          await ImageRepository.instance.uploadMultiple(_pickedImages);
        }
      } on ApiException catch (e) {
        if (mounted) {
          AppDialog.show(
            context,
            title:   '이미지 업로드 실패',
            message: e.message,
          );
          setState(() => _isSubmitting = false);
        }
        return;
      }
    }

    try {
      await ReportRepository.instance.createReport(
        ReportCreateRequest(
          companyName:  _companyController.text.trim(),
          contactType:  _contactTypeMap[_selectedContactType]!,
          contactValue: _contactValueController.text.trim(),
          reason:       _reasonController.text.trim(),
          evidence:     _evidenceController.text.trim(),
          imageNames:   imageNames,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('피해 사례가 등록되었습니다.')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) {
        AppDialog.show(
          context,
          title:   '등록 실패',
          message: e.message,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title:          '피해 사례 등록',
        showBackButton: true,
        onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
        profileImageUrl: _profileImageUrl, // [ADDED]
        onProfileTap: () => Navigator.of(context).push( // [ADDED]
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── 섹션 헤더: 기본 정보 ──
            _SectionHeader(title: '기본 정보'),
            AppDimensions.verticalGap16,

            Container(
              width:   double.infinity,
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(label: '회사', isRequired: true),
                  const SizedBox(height: 8),
                  _OutlinedTextField(
                    controller: _companyController,
                    hintText:   '회사 이름을 입력해 주세요',
                  ),

                  const SizedBox(height: 20),

                  const _FieldLabel(label: '연락 수단', isRequired: true),
                  const SizedBox(height: 8),
                  AppDropdown(
                    value:     _selectedContactType,
                    hintText:  '연락 수단을 선택해 주세요',
                    items:     _contactTypes,
                    onChanged: (v) => setState(() => _selectedContactType = v),
                  ),

                  const SizedBox(height: 20),

                  const _FieldLabel(label: '연락 정보', isRequired: true),
                  const SizedBox(height: 8),
                  _OutlinedTextField(
                    controller: _contactValueController,
                    hintText:   _contactValueHint,
                  ),
                ],
              ),
            ),

            AppDimensions.verticalGap16,

            // ── 섹션 헤더: 신고 사유 ──
            _SectionHeader(title: '신고 사유'),
            AppDimensions.verticalGap16,

            Container(
              width:   double.infinity,
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(label: '피해 내용', isRequired: true),
                  const SizedBox(height: 8),
                  _OutlinedTextField(
                    controller: _reasonController,
                    hintText:   '당시 피해 상황을 상세히 기재해주세요.',
                    maxLines:   5,
                  ),
                ],
              ),
            ),

            AppDimensions.verticalGap16,

            // ── 섹션 헤더: 증거 자료 ──
            _SectionHeader(title: '증거 자료'),
            AppDimensions.verticalGap16,

            Container(
              width:   double.infinity,
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지 업로드 (선택)
                  const _FieldLabel(label: '이미지 업로드 (선택)'),
                  const SizedBox(height: 4),
                  Text(
                    'ex) 채팅 내용, 공고 내용 캡쳐본',
                    style: AppTypography.small12.copyWith(color: AppColors.gray500),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 88,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _pickedImages.length < 4
                          ? _pickedImages.length + 1
                          : 4,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, index) {
                        if (index < _pickedImages.length) {
                          return _ImageSlot(
                            imageFile: _pickedImages[index],
                            onRemove:  () => _removeImage(index),
                          );
                        }
                        return _ImageSlot(onTap: _pickImage);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 증거 텍스트 (필수)
                  const _FieldLabel(label: '증거', isRequired: true),
                  const SizedBox(height: 8),
                  _OutlinedTextField(
                    controller: _evidenceController,
                    hintText:   '증거 내용을 자유롭게 기재해주세요.',
                    maxLines:   4,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),

      // ── 하단 등록 버튼 (analysis_register.dart와 동일한 패턴) ──
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPadding,
            vertical:   16,
          ),
          child: SizedBox(
            width:  double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor:         AppColors.primary,
                disabledBackgroundColor: AppColors.gray300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                width:  20,
                height: 20,
                child: CircularProgressIndicator(
                  color:       Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                '피해 사례 등록하기',
                style: AppTypography.large16.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 섹션 헤더 ──
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.largeBold16.copyWith(
        fontSize:      18,
        letterSpacing: -0.5,
      ),
    );
  }
}

// ── 필드 레이블 (analysis_register.dart의 _SectionLabel과 동일한 패턴) ──
class _FieldLabel extends StatelessWidget {
  final String label;
  final bool   isRequired;

  const _FieldLabel({required this.label, this.isRequired = false});

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

// ── 외곽선 텍스트 필드 (analysis_register.dart의 _OutlinedTextField와 동일한 패턴) ──
class _OutlinedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String                hintText;
  final int                   maxLines;

  const _OutlinedTextField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color:       AppColors.gray100,
            offset:      const Offset(0, 2),
            blurRadius:  4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines:   maxLines,
        style:      AppTypography.middle14,
        decoration: InputDecoration(
          hintText:  hintText,
          hintStyle: AppTypography.middle14.copyWith(color: AppColors.gray500),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:   const BorderSide(color: AppColors.gray300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:   const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          filled:    true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

// ── 이미지 슬롯 (analysis_register.dart의 _ImageSlot과 동일한 패턴) ──
class _ImageSlot extends StatelessWidget {
  final XFile?       imageFile;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _ImageSlot({this.imageFile, this.onTap, this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (imageFile != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: kIsWeb
                ? Image.network(
              imageFile!.path,
              width:  80,
              height: 80,
              fit:    BoxFit.cover,
            )
                : Image.file(
              File(imageFile!.path),
              width:  80,
              height: 80,
              fit:    BoxFit.cover,
            ),
          ),
          Positioned(
            top:   2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width:  18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  80,
        height: 80,
        decoration: BoxDecoration(
          color:        AppColors.gray200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(
            Icons.add_photo_alternate_outlined,
            color: AppColors.gray500,
            size:  28,
          ),
        ),
      ),
    );
  }
}