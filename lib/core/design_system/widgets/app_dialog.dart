import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';

// 공통 커스텀 다이얼로그
// 사용 예시:
// AppDialog.show(context, title: '오류', message: '로그인에 실패했습니다.');
class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback? onConfirm;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = '확인',
    this.onConfirm,
  });

  static Future<void> show(
      BuildContext context, {
        required String title,
        required String message,
        String confirmLabel = '확인',
        VoidCallback? onConfirm,
      }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.primary, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTypography.largeBold16.copyWith(letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTypography.middle14.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  confirmLabel,
                  style: AppTypography.large16.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}