import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as web;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samak_fe/core/design_system/app_text_styles.dart';
import 'package:samak_fe/core/network/dio_client.dart';
import 'package:samak_fe/core/network/api_exception.dart';
import 'package:samak_fe/core/design_system/app_dimensions.dart';
import 'package:samak_fe/core/design_system/app_icons.dart';
import '../core/design_system/app_colors.dart';
import '../main.dart';
import '../core/design_system/widgets/app_dialog.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  static bool _isGoogleSignInInitialized = false;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;

  // [MODIFIED] 웹 스토리지 옵션 추가
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    webOptions: WebOptions(dbName: 'samak_db', publicKey: 'samak_key'),
  );
  bool _isLoading = false;

  // 구글 로그인 인스턴스
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  // 리스터 해제
  @override
  void dispose() {
    _authSubscription?.cancel(); // 화면이 닫힐 때 감시 중단
    super.dispose();
  }

  Future<void> _initializeGoogleSignIn() async {
    if (!_isGoogleSignInInitialized) {
      // 웹 전용 클라이언트 ID로만 초기화
      await _googleSignIn.initialize(
        clientId: '813032635406-qrkum54puofurnpj9vfkahlg448gh218.apps.googleusercontent.com',
      );
      _isGoogleSignInInitialized = true; // 초기화 완료 상태로 변경
      debugPrint('Google Sign-In Initialized');
    }

    if (!mounted) return;

    // 리스너를 변수에 할당
    _authSubscription = _googleSignIn.authenticationEvents.listen((event) async {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        final GoogleSignInAccount? account = event.user;
        if (account != null && mounted) {
          await _handleBackendLogin(account);
        }
      }
    });
  }

  // 백엔드 통신 로직 (동일하게 유지하되 모바일 호출부 제거)
  Future <void> _handleBackendLogin(GoogleSignInAccount account) async {
    if (!mounted || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAuthentication googleAuth = account.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('구글 인증 토큰을 생성할 수 없습니다.');
      }

      final data = await DioClient.instance.post(
        '/api/v1/auth/oauth2/login',
        data: {
          'provider': 'GOOGLE',
          'idToken': idToken,
        },
      );

      if (!mounted) return;

      await _storage.write(key: 'auth_token', value: data['token']?.toString() ?? '');
      await _storage.write(key: 'user_id', value: data['id']?.toString() ?? '');
      await _storage.write(key: 'user_email', value: data['email']?.toString() ?? '');

      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));

    } on ApiException catch (e) {
      if (mounted) AppDialog.show(context, title: '로그인 오류', message: e.message);
    } catch (e) {
      debugPrint('Login Error: $e'); // 디버깅용 로그
      if (mounted) AppDialog.show(context, title: '로그인 오류', message: '인증 과정에서 문제가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              SvgPicture.asset(AppIcons.title, width: 180, height: 85),
              SizedBox(height: AppDimensions.gapSection),
              Text("사막으로 취업 사기를 함께 막아요", style: AppTypography.large20),
              SizedBox(height: AppDimensions.gapSection + 20.0),

              // ── 웹 전용 버튼만 렌더링 ──
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: SizedBox(
                    height: 64,
                    width: 300, // 웹 환경에 맞게 고정 너비 설정
                    child: web.renderButton(
                      configuration: web.GSIButtonConfiguration(
                        theme: web.GSIButtonTheme.outline,
                        shape: web.GSIButtonShape.pill,
                        text: web.GSIButtonText.continueWith,
                        logoAlignment: web.GSIButtonLogoAlignment.center,
                        size: web.GSIButtonSize.large,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.gapSection),
              const CascadingVerificationCards(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 촤라락 내려오는 카드 애니메이션 위젯──
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

        // [MODIFIED] Padding 좌우 고정값 제거, IntrinsicWidth로 텍스트 너비에 맞게 박스 크기 결정
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

  // [MODIFIED] IntrinsicWidth로 감싸서 텍스트 너비 기준으로 박스가 결정되도록 변경, 최소 너비 160 보장
  Widget _buildInfoCard(String text) {
    return Center(
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 160),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12.0),
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
            child: Text(
              text,
              style: AppTypography.large16.copyWith(
                color: AppColors.info,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}