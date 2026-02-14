import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Roboto';

  // 9. Highlight Bold 24pt
  static const TextStyle highlightBold24 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.gray900,
  );

  // 1. Large text 20pt
  static const TextStyle large20 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.gray900,
  );

  // 2. Large text 16pt
  static const TextStyle large16 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.gray900,
  );

  // 3. Large text Bold 16pt
  static const TextStyle largeBold16 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.gray900,
  );

  // 3.5 Middle text 13pt
  static const TextStyle middle13 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // 4. Middle text 14pt
  static const TextStyle middle14 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.gray900,
  );

  // 5. Small text 12pt
  static const TextStyle small12 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.gray900,
  );

  // 6. Small text Bold 12pt
  static const TextStyle smallBold12 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.gray900,
  );

  // 7. Small text 10pt
  static const TextStyle small10 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.gray500,
  );

  // 8. Small text 8pt
  static const TextStyle small8 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 8,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.gray500,
  );
}