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
import '../core/design_system/app_text_styles.dart';

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

      // final bool isOnboarded = data['isOnboarded'] as bool;
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppIcons.title,
            width: 180,
            height: 85,
          ),
          SizedBox(height: AppDimensions.gapSection),
          Text(
            "사막으로 취업 사기를 함께 막아요",
            style: AppTypography.large20
          ),
          SizedBox(height: AppDimensions.gapSection + 20.0),
          Center(
            child: _isLoading
                ? const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ) :
            Padding(
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
          SizedBox(height: AppDimensions.gapSection,),
          Text(
            "사막을 통해 아래 정보들을 검증할 수 있어요",
            style: AppTypography.small12.copyWith(color: AppColors.gray500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}