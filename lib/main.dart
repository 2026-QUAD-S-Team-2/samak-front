import 'package:flutter/material.dart';
import 'core/design_system/widgets/app_header.dart';
import 'core/design_system/widgets/app_navigationbar.dart';
import 'core/design_system/app_text_styles.dart';
import 'core/design_system/app_colors.dart';
import 'screens/home.dart';
import 'screens/analysis_list.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/login_screen.dart';
import 'screens/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const LoadingScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      _PlaceholderScreen(title: '소식'),
      AnalysisListScreen(
        onBackToHome: () => setState(() => _selectedIndex = 0),
      ),
      _PlaceholderScreen(title: '게시판'),
      _PlaceholderScreen(title: '프로필'),
    ];
  }

  final List<String> _titles = [
    ' ',
    '소식',
    '분석 전체 리스트',
    '게시판',
    '프로필',
  ];

  @override
  Widget build(BuildContext context) {
    final bool showAppBar = _selectedIndex != 0 && _selectedIndex != 2;

    return Scaffold(
      appBar: showAppBar ? AppHeader(title: _titles[_selectedIndex]) : null,
      body: _buildScreens()[_selectedIndex],
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

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gray100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: AppColors.gray300,
            ),
            const SizedBox(height: 16),
            Text(
              '$title 화면',
              style: AppTypography.large20.copyWith(
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '준비 중입니다',
              style: AppTypography.middle14.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}