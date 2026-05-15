// [ADDED] 게시글 등록 화면
// POST /api/v1/board/posts
// - 카테고리, 글 제목, 글 내용 (필수)
// - 이미지 업로드 (선택, 최대 4장)
// - 분석 결과 공유 카테고리 선택 시 analysisItemId 입력 필드 노출
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/widgets/app_header.dart';
import '../core/design_system/widgets/app_dropdown.dart';
import '../core/design_system/widgets/app_dialog.dart';
import '../data/repositories/board_repository.dart';
import '../data/repositories/image_repository.dart';
import '../data/repositories/member_repository.dart';
import '../data/models/board_model.dart';
import '../core/network/api_exception.dart';
import '../screens/profile_screen.dart';

class BoardRegisterScreen extends StatefulWidget {
  const BoardRegisterScreen({super.key});

  @override
  State<BoardRegisterScreen> createState() => _BoardRegisterScreenState();
}

class _BoardRegisterScreenState extends State<BoardRegisterScreen> {
  final TextEditingController _titleController         = TextEditingController();
  final TextEditingController _contentController       = TextEditingController();
  final TextEditingController _analysisItemIdController = TextEditingController();

  String? _selectedCategory;
  bool    _isSubmitting    = false;
  String? _profileImageUrl;

  final ImagePicker _imagePicker  = ImagePicker();
  final List<XFile> _pickedImages = [];

  // 카테고리 한국어 → API 값 매핑
  static const Map<String, String> _categoryMap = {
    '경험담':        'EXPERIENCE',
    '사기 의심 투표': 'FRAUD_VOTE',
    '분석 결과 공유': 'ANALYSIS_SHARE',
  };
  final List<String> _categoryLabels = _categoryMap.keys.toList();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _analysisItemIdController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final member = await MemberRepository.instance.getMe();
      if (mounted) setState(() => _profileImageUrl = member.profileImageUrl);
    } catch (_) {}
  }

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

  Future<void> _submit() async {
    if (_selectedCategory == null ||
        _titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 항목을 모두 입력해 주세요.')),
      );
      return;
    }

    // 분석 결과 공유 카테고리인 경우 analysisItemId 필수
    int? analysisItemId;
    if (_categoryMap[_selectedCategory] == 'ANALYSIS_SHARE') {
      final idText = _analysisItemIdController.text.trim();
      if (idText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('연결할 분석 아이템 ID를 입력해 주세요.')),
        );
        return;
      }
      analysisItemId = int.tryParse(idText);
      if (analysisItemId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('분석 아이템 ID는 숫자여야 합니다.')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    // 이미지 업로드 (선택)
    List<String> imageNames = [];
    if (_pickedImages.isNotEmpty) {
      try {
        if (_pickedImages.length == 1) {
          imageNames = [
            await ImageRepository.instance.uploadSingle(_pickedImages.first),
          ];
        } else {
          imageNames = await ImageRepository.instance.uploadMultiple(_pickedImages);
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
      await BoardRepository.instance.createPost(
        BoardPostCreateRequest(
          category:       _categoryMap[_selectedCategory]!,
          title:          _titleController.text.trim(),
          content:        _contentController.text.trim(),
          imageNames:     imageNames,
          analysisItemId: analysisItemId,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 등록되었습니다.')),
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
    final bool isAnalysisShare =
        _categoryMap[_selectedCategory] == 'ANALYSIS_SHARE';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title:          '게시글 등록',
        showBackButton: true,
        onBack:         () => Navigator.of(context).maybePop(),
        profileImageUrl: _profileImageUrl,
        onProfileTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 섹션 헤더 ──
            Text(
              '게시글 등록',
              style: AppTypography.large20.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '공유하고 싶은 글을 작성해주세요.',
              style: AppTypography.small12.copyWith(
                color: AppColors.gray500,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 24),

            // ── 기본 정보 섹션 ──
            _SectionHeader(title: '기본 정보'),
            AppDimensions.verticalGap16,

            Container(
              width:   double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리
                  const _FieldLabel(label: '카테고리', isRequired: true),
                  const SizedBox(height: 8),
                  AppDropdown(
                    value:     _selectedCategory,
                    hintText:  '카테고리를 선택해주세요.',
                    items:     _categoryLabels,
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  ),

                  const SizedBox(height: 20),

                  // 글 제목
                  const _FieldLabel(label: '글 제목', isRequired: true),
                  const SizedBox(height: 8),
                  _OutlinedTextField(
                    controller: _titleController,
                    hintText:   '제목을 입력해주세요.',
                  ),

                  const SizedBox(height: 20),

                  // 글 내용
                  const _FieldLabel(label: '글 내용', isRequired: true),
                  const SizedBox(height: 8),
                  _OutlinedTextField(
                    controller: _contentController,
                    hintText:   '글 내용을 작성해주세요.',
                    maxLines:   6,
                  ),

                  // 분석 결과 공유 카테고리 선택 시 analysisItemId 입력 필드 노출
                  if (isAnalysisShare) ...[
                    const SizedBox(height: 20),
                    const _FieldLabel(label: '분석 아이템 ID', isRequired: true),
                    const SizedBox(height: 8),
                    _OutlinedTextField(
                      controller: _analysisItemIdController,
                      hintText:   '연결할 분석 아이템 ID를 입력해주세요.',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── 이미지 업로드 섹션 ──
            _SectionHeader(title: '이미지 업로드'),
            AppDimensions.verticalGap16,

            Container(
              width:   double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(label: '이미지 (선택)'),
                  const SizedBox(height: 4),
                  Text(
                    'ex) 채팅 내용 캡쳐',
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
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),

      // ── 하단 등록 버튼 ──
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
                '게시글 등록하기',
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

// ── 필드 레이블 ──
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

// ── 외곽선 텍스트 필드 ──
class _OutlinedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String                hintText;
  final int                   maxLines;
  final TextInputType?        keyboardType;

  const _OutlinedTextField({
    required this.controller,
    required this.hintText,
    this.maxLines    = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:   controller,
      maxLines:     maxLines,
      keyboardType: keyboardType,
      style:        AppTypography.middle14,
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
    );
  }
}

// ── 이미지 슬롯 ──
class _ImageSlot extends StatelessWidget {
  final XFile?        imageFile;
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
              width: 80, height: 80, fit: BoxFit.cover,
            )
                : Image.file(
              File(imageFile!.path),
              width: 80, height: 80, fit: BoxFit.cover,
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