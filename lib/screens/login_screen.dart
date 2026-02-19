import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../core/design_system/app_colors.dart';
import '../main.dart';

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
        throw Exception("ID Token을 가져오지 못했습니다.");
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
      }
    } catch (e) {
      print("Google Login Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
          onPressed: _handleGoogleLogin,
          icon: const Icon(Icons.login),
          label: const Text('Google로 로그인'),
        ),
      ),
    );
  }
}