import 'package:flutter/material.dart';

class AppDimensions {
  AppDimensions._();

  // --- [1] System & Bar Heights ---
  static const double statusBarHeight = 52.0;
  static const double topBarHeight = 64.0;
  static const double totalTopHeight = 116.0;
  static const double bottomSafeArea = 24.0;
  static const double navigatorBarHeight = 55.0;
  static const double navBarHorizontalPadding = 32.0;
  static const double navBarVerticalPadding = 10.0;

  // --- [2] Spacing & Padding (Basic) ---
  static const double screenPadding = 16.0;   // 화면 가장 자리 ↔ 콘텐츠
  static const double cardPadding = 16.0;     // 카드 내부 Padding

  static const double gapCardToCardSmall = 12.0; // 카드 ↔ 카드 (좁게)
  static const double gapCardToCard = 16.0;      // 카드 ↔ 카드 (기본)
  static const double gapSection = 24.0;         // 큰 덩어리 구분 (Section)

  // --- [3] Pre-defined EdgeInsets ---
  static const EdgeInsets screenEdgePadding = EdgeInsets.symmetric(horizontal: screenPadding);
  static const EdgeInsets allSidePadding = EdgeInsets.all(screenPadding);
  static const EdgeInsets cardInnerPadding = EdgeInsets.all(cardPadding);

  // --- [4] Gap Widgets ---
  // 수직 간격
  static const SizedBox verticalGap12 = SizedBox(height: gapCardToCardSmall);
  static const SizedBox verticalGap16 = SizedBox(height: gapCardToCard);
  static const SizedBox verticalGap24 = SizedBox(height: gapSection);

  // 수평 간격
  static const SizedBox horizontalGap12 = SizedBox(width: gapCardToCardSmall);
  static const SizedBox horizontalGap16 = SizedBox(width: gapCardToCard);
}