import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/widgets/app_dialog.dart';
import '../core/design_system/app_icons.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/member_repository.dart';
import '../data/models/member_model.dart';
import '../core/network/api_exception.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  MemberModel? _member;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  Future<void> _loadMember() async {
    try {
      final member = await MemberRepository.instance.getMe();
      setState(() => _member = member);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    // 로그아웃 확인 다이얼로그
    AppDialog.show(
      context,
      title: '로그아웃',
      message: '정말 로그아웃 하시겠어요?',
      confirmLabel: '로그아웃',
      onConfirm: () async {
        try {
          await AuthRepository.instance.logout();
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false, // 모든 스택 제거 후 로그인 화면으로
          );
        } on ApiException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message)),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          children: [
            // ── 프로필 카드 ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // 프로필 이미지
                  ClipOval(
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: (_member?.profileImageUrl != null &&
                          _member!.profileImageUrl!.isNotEmpty)
                          ? Image.network(
                        _member!.profileImageUrl!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => SvgPicture.asset(
                          AppIcons.defaultProfile,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      )
                          : SvgPicture.asset(
                        AppIcons.defaultProfile,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _member != null
                              ? '${_member!.nickname}님'
                              : '사용자님',
                          style: AppTypography.largeBold16.copyWith(
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _member?.email ?? '',
                          style: AppTypography.small12.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            AppDimensions.verticalGap16,

            // ── 로그아웃 버튼 ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: const BorderSide(color: AppColors.error, width: 1),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '로그아웃',
                  style: AppTypography.large16.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}