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
import 'screens/report_list.dart';
import 'data/repositories/auth_repository.dart'; // [MODIFIED] 로그아웃을 위한 AuthRepository import 추가

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

  // [MODIFIED] 로그아웃 처리 메서드 추가
  Future<void> _onLogout() async {
    try {
      await AuthRepository.instance.logout();
    } catch (e) {
      debugPrint('로그아웃 실패: $e');
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoadingScreen()),
          (route) => false,
    );
  }

  // [MODIFIED] 선택 여부에 따라 아이콘·텍스트 색상을 분기하는 Drawer 메뉴 항목 빌더 추가
  Widget _buildDrawerItem({
    required String icon,
    required String filledIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;
    final Color contentColor = isSelected ? AppColors.gray900 : AppColors.gray500;
    return ListTile(
      leading: SvgPicture.asset(
        isSelected ? filledIcon : icon,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
      ),
      title: Text(
        label,
        style: AppTypography.middle14.copyWith(
          color: contentColor,
          letterSpacing: -0.3,
        ),
      ),
      onTap: () => _onItemTapped(index),
    );
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
        onProfileTap: () {
          setState(() {
            _selectedIndex = 4;
          });
        },
      ),
      // [MODIFIED] 사이드바 디자인 전면 변경: 로고+X 헤더 / 선택 시 Filled 아이콘 / 하단 로그아웃+프로필
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        backgroundColor: AppColors.surfacePrimary,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 헤더: 앱 로고 + X 닫기 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    SvgPicture.asset(AppIcons.appBarTitle, height: 24),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, size: 24, color: AppColors.gray900),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // 메뉴 항목: 선택 시 Filled 아이콘 + 진한 색, 미선택 시 outline 아이콘 + 회색
              _buildDrawerItem(
                icon: AppIcons.home,
                filledIcon: AppIcons.homeFilled,
                label: '홈',
                index: 0,
              ),
              _buildDrawerItem(
                icon: AppIcons.heart,
                filledIcon: AppIcons.heartFilled,
                label: '소식',
                index: 1,
              ),
              _buildDrawerItem(
                icon: AppIcons.add,
                filledIcon: AppIcons.addFilled,
                label: '분석',
                index: 2,
              ),
              _buildDrawerItem(
                icon: AppIcons.chatDots,
                filledIcon: AppIcons.chatDotsFilled,
                label: '게시판',
                index: 3,
              ),
              _buildDrawerItem(
                icon: AppIcons.user,
                filledIcon: AppIcons.userFilled,
                label: '프로필',
                index: 4,
              ),
              const Spacer(),
              // 로그아웃 버튼
              ListTile(
                leading: const Icon(Icons.logout, size: 20, color: AppColors.gray500),
                title: Text(
                  '로그아웃',
                  style: AppTypography.middle14.copyWith(
                    color: AppColors.gray500,
                    letterSpacing: -0.3,
                  ),
                ),
                onTap: _onLogout,
              ),
              const Divider(height: 1, color: AppColors.gray200),
              // 하단 사용자 프로필 영역
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: (_member?.profileImageUrl != null &&
                            _member!.profileImageUrl!.isNotEmpty)
                            ? Image.network(
                          _member!.profileImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              SvgPicture.asset(AppIcons.defaultProfile),
                        )
                            : SvgPicture.asset(AppIcons.defaultProfile),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _member != null ? '${_member!.nickname}님' : '사용자님',
                          style: AppTypography.middle14.copyWith(
                            color: AppColors.gray900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          _member?.email ?? '',
                          style: AppTypography.small12.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      const ReportListScreen(),
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