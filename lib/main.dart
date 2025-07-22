import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/verse_provider.dart';
import 'screens/calendar_screen.dart';
import 'screens/age_group_screen.dart';
import 'screens/monthly_verse_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ChurchSchoolApp());
}

class ChurchSchoolApp extends StatelessWidget {
  const ChurchSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VerseProvider(),
      child: MaterialApp(
        title: '교회학교 암송 어플',
        theme: ThemeData(
          // Tailwind CSS 인스파이어드 색상 팔레트
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1), // indigo-500
            brightness: Brightness.light,
          ).copyWith(
            // 메인 브랜드 색상 (따뜻한 보라/인디고 톤)
            primary: const Color(0xFF6366F1), // indigo-500
            secondary: const Color(0xFF8B5CF6), // violet-500
            tertiary: const Color(0xFF06B6D4), // cyan-500
            
            // 배경 색상 (부드러운 중성 톤)
            surface: const Color(0xFFFAFAFA), // neutral-50
            surfaceContainerHighest: const Color(0xFFF5F5F5), // neutral-100
            surfaceContainer: const Color(0xFFE5E7EB), // gray-200
            
            // 텍스트와 컨트라스트
            onSurface: const Color(0xFF111827), // gray-900
            onSurfaceVariant: const Color(0xFF6B7280), // gray-500
            
            // 액센트 색상
            primaryContainer: const Color(0xFFEEF2FF), // indigo-50
            secondaryContainer: const Color(0xFFF3E8FF), // violet-50
          ),
          useMaterial3: true,
          
          // 폰트 테마 업데이트
          textTheme: GoogleFonts.notoSansKrTextTheme().copyWith(
            displayLarge: GoogleFonts.notoSansKr(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.02,
            ),
            displayMedium: GoogleFonts.notoSansKr(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.01,
            ),
            headlineSmall: GoogleFonts.notoSansKr(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.01,
            ),
            titleLarge: GoogleFonts.notoSansKr(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            titleMedium: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            bodyLarge: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
            bodyMedium: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          
          // 카드 테마 업데이트
          cardTheme: CardThemeData(
            elevation: 0,
            shadowColor: Colors.black.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
          
          // 앱바 테마
          appBarTheme: AppBarTheme(
            elevation: 0,
            scrolledUnderElevation: 1,
            backgroundColor: const Color(0xFFFAFAFA),
            foregroundColor: const Color(0xFF111827),
            titleTextStyle: GoogleFonts.notoSansKr(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          
          // 버튼 테마
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: GoogleFonts.notoSansKr(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isInitialized = false;
  bool _showSplash = true;
  bool _splashTimeCompleted = false;

  @override
  void initState() {
    super.initState();
    // 스플래시와 초기화를 병렬로 시작
    _startSplashTimer();
    _initializeApp();
  }

  // 1.5초 스플래시 타이머
  void _startSplashTimer() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _splashTimeCompleted = true;
          _checkIfReadyToShowMain();
        });
      }
    });
  }

  // 앱 초기화 (스플래시와 병렬 실행)
  Future<void> _initializeApp() async {
    final provider = Provider.of<VerseProvider>(context, listen: false);
    await provider.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
        _checkIfReadyToShowMain();
      });
    }
  }

  // 스플래시 종료 조건 체크
  void _checkIfReadyToShowMain() {
    // 1.5초가 지나고 초기화도 완료되면 메인 화면으로
    if (_splashTimeCompleted && _isInitialized) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 스플래시 화면 표시
    if (_showSplash) {
      return SplashScreen(
        onFinished: () {
          // 더 이상 여기서 처리하지 않음 (병렬 처리로 변경)
        },
      );
    }
    
    if (!_isInitialized) {
      return _buildInitializationScreen();
    }

    return Consumer<VerseProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return _buildErrorScreen(provider);
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              CalendarScreen(),
              AgeGroupScreen(sheetName: '유치부', displayName: '유치부'),
              AgeGroupScreen(sheetName: '초등부', displayName: '초등부'),
              MonthlyVerseScreen(),
              AgeGroupScreen(sheetName: '중고등부', displayName: '중고등부'),
            ],
          ),
          bottomNavigationBar: _buildCustomBottomNavBar(),
        );
      },
    );
  }

  // 앱 초기화 화면
  Widget _buildInitializationScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA), // custom blue
              Color(0xFF764BA2), // custom purple
              Color(0xFFF093FB), // light pink
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 아이콘 컨테이너
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1200),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.church_rounded,
                        size: 80,
                        color: Color(0xFF667EEA),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 48),
              
              // 로딩 인디케이터
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 앱 타이틀
              const Text(
                '교회학교 암송 어플',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.02,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // 서브타이틀
              Text(
                '하나님의 말씀으로 마음을 채워요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // 초기화 메시지
              Text(
                '앱을 초기화하는 중...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 에러 화면
  Widget _buildErrorScreen(VerseProvider provider) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFEF2F2), // red-50
              Color(0xFFFDF2F8), // pink-50
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 80,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  '앱 초기화 중 문제가 발생했어요',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _initializeApp(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('다시 시도'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 커스텀 바텀 네비게이션 바
  Widget _buildCustomBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFAFAFA),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF6366F1),
          unselectedItemColor: const Color(0xFF9CA3AF),
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            _buildNavItem(
              icon: Icons.calendar_today_rounded,
              activeIcon: Icons.calendar_today_rounded,
              label: '캘린더',
              index: 0,
            ),
            _buildNavItem(
              icon: Icons.child_care_outlined,
              activeIcon: Icons.child_care_rounded,
              label: '유치부',
              index: 1,
            ),
            _buildNavItem(
              icon: Icons.school_outlined,
              activeIcon: Icons.school_rounded,
              label: '초등부',
              index: 2,
            ),
            _buildNavItem(
              icon: Icons.auto_awesome_outlined,
              activeIcon: Icons.auto_awesome_rounded,
              label: '월암송',
              index: 3,
            ),
            _buildNavItem(
              icon: Icons.groups_outlined,
              activeIcon: Icons.groups_rounded,
              label: '중고등부',
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  // 네비게이션 아이템 빌더
  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    
    return BottomNavigationBarItem(
      icon: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        _getGradientColors(index)[0].withOpacity(0.15),
                        _getGradientColors(index)[1].withOpacity(0.1),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(
                      color: _getGradientColors(index)[0].withOpacity(0.2),
                      width: 1,
                    )
                  : null,
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected
                  ? _getGradientColors(index)[0]
                  : const Color(0xFF9CA3AF),
            ),
          );
        },
      ),
      label: label,
    );
  }

  // 인덱스별 그라데이션 색상
  List<Color> _getGradientColors(int index) {
    switch (index) {
      case 0: // 캘린더
        return [const Color(0xFF3B82F6), const Color(0xFF1E40AF)]; // blue
      case 1: // 유치부
        return [const Color(0xFF8B5CF6), const Color(0xFFA855F7)]; // violet
      case 2: // 초등부
        return [const Color(0xFF6366F1), const Color(0xFF4F46E5)]; // indigo
      case 3: // 월암송
        return [const Color(0xFF667EEA), const Color(0xFF764BA2)]; // custom gradient
      case 4: // 중고등부
        return [const Color(0xFF10B981), const Color(0xFF059669)]; // emerald
      default:
        return [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
    }
  }
}
