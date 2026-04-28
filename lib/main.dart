import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'core/design_system/widgets/app_header.dart';
import 'core/design_system/app_text_styles.dart';
import 'core/design_system/app_icons.dart';
import 'core/design_system/app_colors.dart';
import 'screens/home.dart';
import 'screens/analysis_list.dart';
import 'screens/loading_screen.dart';
import 'screens/profile_screen.dart';
import 'data/repositories/member_repository.dart';
import 'data/models/member_model.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.gray900,
          contentTextStyle: AppTypography.middle14.copyWith(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MemberModel? _member;

  @override
  void initState() {
    super.initState();
    _loadMemberInfo();
  }

  Future<void> _loadMemberInfo() async {
    try {
      final member = await MemberRepository.instance.getMe(); //
      setState(() => _member = member);
    } catch (e) {
      debugPrint('회원 정보 로드 실패: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // 공통 헤더 적용: "사막" 타이틀, 메뉴 버튼, 프로필 이미지 연결
      appBar: AppHeader(
        title: _titles[_selectedIndex],
        showMenuButton: true,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        profileImageUrl: _member?.profileImageUrl,
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.65,
        backgroundColor: AppColors.surfacePrimary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _member != null ? '${_member!.nickname} 님' : '사용자님',
                    style: AppTypography.large20.copyWith(color: Colors.white, letterSpacing: -0.3),
                  ),
                  SizedBox(height: 5),
                  Text(
                    _member?.email ?? '',
                    style: AppTypography.small12.copyWith(color: AppColors.purple100),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: SvgPicture.asset(AppIcons.homeFilled, width: 20, height: 20),
              title: Text('홈', style: AppTypography.middle14.copyWith(color: AppColors.gray900, letterSpacing: -0.3),
              ),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: SvgPicture.asset(AppIcons.heartFilled, width: 20, height: 20),
              title: Text('소식', style: AppTypography.middle14.copyWith(color: AppColors.gray900, letterSpacing: -0.3)),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: SvgPicture.asset(AppIcons.addFilled, width: 20, height: 20),
              title: Text('분석', style: AppTypography.middle14.copyWith(color: AppColors.gray900, letterSpacing: -0.3),),
              selected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: SvgPicture.asset(AppIcons.chatDotsFilled, width: 20, height: 20),
              title: Text('게시판', style: AppTypography.middle14.copyWith(color: AppColors.gray900, letterSpacing: -0.3),),
              selected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: SvgPicture.asset(AppIcons.userFilled, width: 20, height: 20),
              title: Text('프로필', style: AppTypography.middle14.copyWith(color: AppColors.gray900, letterSpacing: -0.3),),
              selected: _selectedIndex == 4,
              onTap: () => _onItemTapped(4),
            ),
          ],
        ),
      ),
      body: _buildScreens()[_selectedIndex],
    );
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(
        onProfileTap: () => setState(() => _selectedIndex = 4),
      ),
      _PlaceholderScreen(title: '소식'),
      AnalysisListScreen(
        key: ValueKey(_selectedIndex),
        onBackToHome: () => setState(() => _selectedIndex = 0),
      ),
      _PlaceholderScreen(title: '게시판'),
      const ProfileScreen(),
    ];
  }

  final List<String> _titles = [
    '사막',
    '소식',
    '분석 전체 리스트',
    '게시판',
    '프로필',
  ];

  /*
  @override
  Widget build(BuildContext context) {
    final bool showAppBar = _selectedIndex != 0 && _selectedIndex != 2 && _selectedIndex != 4;
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
  */
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