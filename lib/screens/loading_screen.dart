import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design_system/app_icons.dart';
import '../core/design_system/app_colors.dart';
import 'login_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    const storage = FlutterSecureStorage();

    final results = await Future.wait([
      storage.read(key: 'auth_token'),
      Future.delayed(const Duration(seconds: 2)),
    ]);

    if (!mounted) return;

    final String? token = results[0] as String?;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => token != null ? LoginScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppIcons.title2,
              width: 391,
              height: 87,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}