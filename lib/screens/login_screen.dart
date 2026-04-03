import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samak_fe/core/design_system/app_text_styles.dart';
import 'package:samak_fe/core/network/dio_client.dart';
import 'package:samak_fe/core/network/api_exception.dart';
import 'package:samak_fe/core/design_system/app_dimensions.dart';
import 'package:samak_fe/core/design_system/app_icons.dart';
import '../core/design_system/app_colors.dart';
import '../main.dart';
import '../core/design_system/widgets/app_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      // ── Google 인증 ──
      await GoogleSignIn.instance.initialize(
        serverClientId: '813032635406-c9l4qiv9lijsfjpovhvu1k9ggfnohg4d.apps.googleusercontent.com',
      );

      final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate();
      final String? idToken = account.authentication.idToken;

      if (idToken == null) {
        if (mounted) {
          AppDialog.show(
            context,
            title: '로그인 오류',
            message: '인증 토큰을 가져올 수 없습니다.\n잠시 후 다시 시도해 주세요.',
          );
        }
        return;
      }

      // 독자적 Dio 인스턴스 → DioClient.instance 사용
      final data = await DioClient.instance.post(
        '/api/v1/auth/oauth2/login',
        data: {
          'provider': 'GOOGLE',
          'idToken': idToken,
        },
      );

      // statusCode 분기 제거 — ApiException이 throw되지 않으면 성공
      await _storage.write(key: 'auth_token', value: data['token'] as String);
      await _storage.write(key: 'user_id',    value: (data['id'] as int).toString());
      await _storage.write(key: 'user_email', value: data['email'] as String);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainScreen()),
      );

      // ApiException: DioClient 에서 변환된 서버/네트워크 에러 처리
    } on ApiException catch (e) {
      if (mounted) {
        AppDialog.show(context, title: '로그인 오류', message: e.message);
      }

      // Google 로그인 전용 에러 처리 (sign_in_canceled, sign_in_failed 등)
    } catch (e) {
      if (!mounted) return;

      final String errorStr = e.toString();
      final String message;

      if (errorStr.contains('cancel') || errorStr.contains('sign_in_canceled')) {
        message = '로그인이 취소되었습니다.';
      } else if (errorStr.contains('sign_in_failed')) {
        message = 'Google 로그인에 실패했습니다.\n잠시 후 다시 시도해 주세요.';
      } else {
        message = '알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요.';
      }

      AppDialog.show(context, title: '로그인 오류', message: message);

    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80), // 상단 여유 공간
              SvgPicture.asset(
                AppIcons.title,
                width: 180,
                height: 85,
              ),
              SizedBox(height: AppDimensions.gapSection),
              Text(
                "사막으로 취업 사기를 함께 막아요",
                style: AppTypography.large20,
              ),
              SizedBox(height: AppDimensions.gapSection + 20.0),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                )
                    : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: OutlinedButton.icon(
                    onPressed: _handleGoogleLogin,
                    icon: Image.asset(
                      AppIcons.googleIcon,
                      width: 20,
                      height: 20,
                    ),
                    label: const Text(
                      '구글 계정으로 계속하기',
                      style: TextStyle(color: AppColors.gray900),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.gray300),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.gapSection),

              const CascadingVerificationCards(),

              const SizedBox(height: 40), // 하단 여유 공간
            ],
          ),
        ),
      ),
    );
  }
}

// ── 촤라락 내려오는 카드 애니메이션 위젯 ──
class CascadingVerificationCards extends StatefulWidget {
  const CascadingVerificationCards({super.key});

  @override
  State<CascadingVerificationCards> createState() => _CascadingVerificationCardsState();
}

class _CascadingVerificationCardsState extends State<CascadingVerificationCards>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconRotation;

  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  final List<String> _cardContents = [
    '신뢰도 측정',
    '국가 기반 검증',
    '나라별 최저 임금',
  ];

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _iconRotation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimations = [];
    _fadeAnimations = [];

    for (int i = 0; i < _cardContents.length; i++) {
      double start = i * 0.2;
      double end = start + 0.6;
      if (end > 1.0) end = 1.0;

      final curve = CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOutQuart),
      );

      _slideAnimations.add(Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(curve));
      _fadeAnimations.add(Tween<double>(begin: 0.0, end: 1.0).animate(curve));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleExpansion,
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              Text(
                "사막을 통해 아래 정보들을 검증할 수 있어요",
                style: AppTypography.small12.copyWith(color: AppColors.gray500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              RotationTransition(
                turns: _iconRotation,
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.gray500,
                  size: 28,
                ),
              ),
            ],
          ),
        ),

        SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: List.generate(_cardContents.length, (index) {
                return FadeTransition(
                  opacity: _fadeAnimations[index],
                  child: SlideTransition(
                    position: _slideAnimations[index],
                    child: _buildInfoCard(_cardContents[index]),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12.0, left: 120.0, right: 120.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: AppTypography.large16.copyWith(
              color: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }
}