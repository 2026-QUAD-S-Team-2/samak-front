import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
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
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://samak.mooo.com'));

  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: '813032635406-c9l4qiv9lijsfjpovhvu1k9ggfnohg4d.apps.googleusercontent.com',
      );

      final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate();

      final String? idToken = account.authentication.idToken;

      if (idToken == null) {
        AppDialog.show(
            context,
            title: '로그인 오류',
            message: '인증 토큰을 가져올 수 없습니다.\n잠시 후 다시 시도해 주세요.'
        );
      }

      final response = await _dio.post(
        '/api/v1/auth/oauth2/login',
        data: {
          'provider': 'GOOGLE',
          'idToken': idToken,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await _storage.write(key: 'auth_token', value: data['token']);

        await _storage.write(key: 'user_id', value: data['id'].toString());
        await _storage.write(key: 'user_email', value: data['email']);

        if (!mounted) return;

        // final bool isOnboarded = data['isOnboarded'];
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      } else {
        AppDialog.show(
          context,
          title: '로그인 오류',
          message: '서버 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요.',
        );
      }
    } catch (e) {
      final String message;
      final String errorStr = e.toString();

      if (errorStr.contains('network') || errorStr.contains('SocketException')) {
        message = '네트워크 연결을 확인해 주세요.';
      } else if (errorStr.contains('cancel') || errorStr.contains('sign_in_canceled')) {
        message = '로그인이 취소되었습니다.';
      } else if (errorStr.contains('sign_in_failed')) {
        message = 'Google 로그인에 실패했습니다.\n잠시 후 다시 시도해 주세요.';
      } else {
        message = '알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요.';
      }

      if (mounted) {
        AppDialog.show(context, title: '로그인 오류', message: message);
      }
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
          SizedBox(height: AppDimensions.gapSection,),
          Center(
            child: _isLoading
                ? const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            )
                : ElevatedButton.icon(
              onPressed: _handleGoogleLogin,
              icon: const Icon(Icons.login, color: AppColors.primary),
              label: const Text(
                'Google로 로그인',
                style: TextStyle(
                  color: AppColors.primary
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                minimumSize: const Size(130, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 2.0, // 그림자 제거
              ),
            ),
          ),
        ]
      ),
    );
  }
}