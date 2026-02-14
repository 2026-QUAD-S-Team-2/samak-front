import 'package:flutter/material.dart';
import 'core/design_system/widgets/app_header.dart';
import 'core/design_system/widgets/app_navigationbar.dart';
import 'core/design_system/app_text_styles.dart';

void main() {
  runApp(const SamakFEApp());
}

class SamakFEApp extends StatelessWidget {
  const SamakFEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SamakFE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "홈 화면"),
      body: Center(child: Text("콘텐츠 영역", style: AppTypography.large20)),

      // 우리가 만든 커스텀 네비게이션 바
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}