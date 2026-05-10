import 'dart:io';

import 'package:flutter/material.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/widgets/app_header.dart';
import '../screens/analysis_result.dart';
import '../core/design_system/widgets/app_dropdown.dart';
import 'package:image_picker/image_picker.dart';
import '../data/repositories/country_repository.dart';
import '../data/repositories/analysis_repository.dart';
import '../data/repositories/image_repository.dart';
import '../data/repositories/member_repository.dart';
import '../screens/profile_screen.dart';
import '../data/models/country_model.dart';
import '../data/models/city_model.dart';
import '../data/models/analysis_item_create_request.dart';
import '../data/models/analysis_item_list_model.dart';
import '../core/network/api_exception.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AnalysisRegisterScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onConfirmResult;
  final VoidCallback? onGoToList;

  const AnalysisRegisterScreen({
    super.key,
    this.onBack,
    this.onConfirmResult,
    this.onGoToList,
  });

  @override
  State<AnalysisRegisterScreen> createState() =>
      _AnalysisRegisterScreenState();
}

class _AnalysisRegisterScreenState extends State<AnalysisRegisterScreen> {
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _etcController = TextEditingController();

  // 서버 데이터 기반 목록 및 모델 선택값
  List<CountryModel> _countries = [];
  List<CityModel> _cities = [];
  bool _isLoadingCountries = false;
  bool _isLoadingCities = false;
  bool _isSubmitting = false;

  CountryModel? _selectedCountry;
  CityModel? _selectedCity;
  String? _selectedChannel;
  String? _profileImageUrl;

  static const Map<String, String> _channelContactTypeMap = {
    '이메일':   'EMAIL',
    '텔레그램': 'TELEGRAM',
    '전화':     'PHONE',
  };
  final List<String> _channels = _channelContactTypeMap.keys.toList();

  // 이미지 관련
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _pickedImages = [];

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _loadProfile();
  }

  @override
  void dispose() {
    _linkController.dispose();
    _companyController.dispose();
    _salaryController.dispose();
    _etcController.dispose();
    super.dispose();
  }

  // 국가 목록 로드
  Future<void> _loadCountries() async {
    setState(() => _isLoadingCountries = true);
    try {
      final countries = await CountryRepository.instance.getCountries();
      setState(() => _countries = countries);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      setState(() => _isLoadingCountries = false);
    }
  }

  // 국가 선택 시 도시 목록 로드
  Future<void> _loadCities(String countryCode) async {
    setState(() {
      _cities = [];
      _selectedCity = null;
      _isLoadingCities = true;
    });
    try {
      final cities = await CountryRepository.instance.getCities(countryCode);
      setState(() => _cities = cities);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      setState(() => _isLoadingCities = false);
    }
  }

  Future<void> _loadProfile() async {
    try {
      final member = await MemberRepository.instance.getMe();
      if (mounted) setState(() => _profileImageUrl = member.profileImageUrl);
    } catch (_) {}
  }

  // 이미지 추가 (최대 4장)
  Future<void> _pickImage() async {
    if (_pickedImages.length >= 4) return;
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (image != null) {
      setState(() => _pickedImages.add(image));
    }
  }

  // 이미지 제거
  void _removeImage(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  // 등록 실행 — 유효성 검사 → 이미지 업로드 → 분석 아이템 등록
  Future<void> _submit() async {
    if (_pickedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지를 1장 이상 첨부해 주세요.')),
      );
      return;
    }
    if (_companyController.text.trim().isEmpty ||
        _selectedCountry == null ||
        _selectedCity == null ||
        _selectedChannel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 항목을 모두 입력해 주세요.')),
      );
      return;
    }

    final salaryText = _salaryController.text.trim();
    double? salary;
    if (salaryText.isNotEmpty) {
      salary = double.tryParse(salaryText);
      if (salary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('제안 임금은 숫자로 입력해 주세요.')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    late List<String> imageNames;
    try {
      if (_pickedImages.length == 1) {
        // .path를 제거하고 XFile 객체 자체를 전달합니다.
        final imageName = await ImageRepository.instance.uploadSingle(
          _pickedImages.first, // String이 아닌 XFile 전달
        );
        imageNames = [imageName];
      } else {
        // .map((e) => e.path).toList() 부분을 제거하고 List<XFile>을 전달합니다.
        imageNames = await ImageRepository.instance.uploadMultiple(
          _pickedImages, // List<XFile> 전달
        );
      }
      debugPrint('[AnalysisRegister] 이미지 업로드 완료 - imageNames: $imageNames');
    } on ApiException catch (e) { // catch (e) 대신 on ApiException catch (e) 사용
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)), // 이제 e.message를 인식합니다.
        );
        setState(() => _isSubmitting = false);
      }
      return;
    } catch (e) { // 그 외 알 수 없는 에러 처리용 (선택 사항)
      debugPrint('Unknown error: $e');
    }

    try {
      // [DEBUG] 요청값 확인을 위해 request 객체 변수로 분리
      final request = AnalysisItemCreateRequest(
        imageNames: imageNames,
        companyName: _companyController.text.trim(),
        countryCode: _selectedCountry!.code,
        cityId: _selectedCity!.id,
        contactType: _channelContactTypeMap[_selectedChannel]!,
        sourceUrl: _linkController.text.trim(),
        notes: _etcController.text.trim(),
        salary: salary ?? 0,
      );
      // [DEBUG] 서버로 보내는 요청값 확인
      debugPrint('[AnalysisRegister] request json: ${request.toJson()}');

      var result = await AnalysisRepository.instance.createItem(request);
      // [DEBUG] 서버 응답 raw 확인 (createItem 내부에서 fromJson 호출 전)
      debugPrint('[AnalysisRegister] createItem 응답 - id: ${result.id}, status: ${result.status}, companyName: ${result.companyName}, countryCode: ${result.countryCode}, sourceUrl: ${result.sourceUrl}, contactType: ${result.contactType}');

      // 상태가 COMPLETED가 될 때까지 API 폴링(대기)
      int pollCount = 0;
      const int maxPollCount = 20; // 3초 * 20번 = 최대 60초 대기 제한

      while ((result.status == AnalysisStatus.pending ||
          result.status == AnalysisStatus.processing) &&
          pollCount < maxPollCount) {
        await Future.delayed(const Duration(seconds: 3));
        result = await AnalysisRepository.instance.getDetail(result.id);
        debugPrint('[AnalysisRegister] 폴링 $pollCount회 - status: ${result.status}');
        pollCount++;
      }

      if (!mounted) return;

      // 최종 상태에 따른 분기 처리
      if (result.status == AnalysisStatus.completed) {
        _showCompletionBottomSheet(result.id);
      } else if (result.status == AnalysisStatus.failed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('분석에 실패했어요. 다시 시도해 주세요.')),
        );
      } else {
        // 타임아웃: 최대 대기 횟수 초과
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('분석이 지연되고 있어요. 완료되면 목록에서 확인할 수 있어요.'),
            duration: Duration(seconds: 4),
          ),
        );
        widget.onGoToList?.call();
      }
    } on ApiException catch (e) {
      debugPrint('[AnalysisRegister] 분석 등록 실패 - statusCode: ${e.statusCode}, message: ${e.message}, raw: ${e.rawResponse}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // analysisItemId를 받아 결과 화면으로 전달
  void _showCompletionBottomSheet(int analysisItemId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (bottomSheetContext) => _CompletionBottomSheet(
        onConfirm: () {
          Navigator.of(bottomSheetContext).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => AnalysisResultScreen(
                analysisItemId: analysisItemId,
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
        title:          '공고 분석 등록',
        showBackButton: true,
        onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
        profileImageUrl: _profileImageUrl, // [ADDED]
        onProfileTap: () => Navigator.of(context).push( // [ADDED]
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          // decoration: BoxDecoration(
          //   // color: Colors.white,
          //   borderRadius: BorderRadius.circular(12),
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 섹션 헤더 ──
              // Padding(
                // padding: const EdgeInsets.only(left: 16),
                // child:
          Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '공고 분석 등록',
                      style: AppTypography.large20.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '분석할 공고의 정보를 입력해 주세요.',
                      style: AppTypography.small12.copyWith(
                        color: AppColors.gray500,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
               //  ),
              ),
              const SizedBox(height: 18,),
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
                        onRemove: () => _removeImage(index),
                      );
                    }
                    return _ImageSlot(onTap: _pickImage);
                  },
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

              // ── 제안 연봉 ──
              const _SectionLabel(label: '제안 연봉'),
              const SizedBox(height: 8),
              _OutlinedTextField(
                controller: _salaryController,
                hintText: '연봉을 입력해 주세요',
              ),

              const SizedBox(height: 20),

              // ── 국가 드롭다운 ──
              const _SectionLabel(label: '국가', isRequired: true),
              const SizedBox(height: 8),
              _isLoadingCountries
                  ? const CircularProgressIndicator()
                  : AppDropdown(
                value: _selectedCountry?.displayName,
                hintText: '국가를 선택해 주세요',
                items: _countries.map((e) => e.displayName).toList(),
                onChanged: (name) {
                  final country = _countries
                      .firstWhere((e) => e.displayName == name);
                  setState(() => _selectedCountry = country);
                  _loadCities(country.code);
                },
              ),

              const SizedBox(height: 20),

              // ── 지역 드롭다운 ──
              const _SectionLabel(label: '지역', isRequired: true),
              const SizedBox(height: 8),
              _isLoadingCities
                  ? const CircularProgressIndicator()
                  : AppDropdown(
                value: _selectedCity?.displayName,
                hintText: '지역을 선택해 주세요',
                items: _cities.map((e) => e.displayName).toList(),
                onChanged: (name) {
                  final city =
                  _cities.firstWhere((e) => e.displayName == name);
                  setState(() => _selectedCity = city);
                },
              ),

              const SizedBox(height: 20),

              // ── 채널(연락 수단) 드롭다운 ──
              const _SectionLabel(label: '연락 수단', isRequired: true),
              const SizedBox(height: 8),
              AppDropdown(
                value: _selectedChannel,
                hintText: '연락 수단을 선택해 주세요',
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPadding,
            vertical: 16,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.gray300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
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
class _ImageSlot extends StatelessWidget {
  final XFile? imageFile;
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
              imageFile!.path, // 웹에서는 Blob URL이 전달됩니다.
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            )
                : Image.file(
              File(imageFile!.path), // 모바일 환경
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 18,
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
  final int maxLines;

  const _OutlinedTextField({
    required this.controller,
    required this.hintText,
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
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTypography.middle14,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.middle14.copyWith(color: AppColors.gray500),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.gray300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
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