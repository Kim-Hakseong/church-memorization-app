import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/verse_provider.dart';
import '../widgets/verse_card.dart';


class AgeGroupScreen extends StatelessWidget {
  final String sheetName;
  final String displayName;
  
  const AgeGroupScreen({
    super.key,
    required this.sheetName,
    required this.displayName,
  });
  
  @override
  Widget build(BuildContext context) {
    return Consumer<VerseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState(context);
        }
        
        if (provider.error != null) {
          return _buildErrorState(context, provider);
        }
        
        return Scaffold(
          // 투명한 앱바로 그라데이션 배경과 연결
          appBar: AppBar(
            title: Text(
              '$displayName 암송구절',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.02,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: _getHeaderGradient(displayName),
            ),
          ),
          extendBodyBehindAppBar: true,
          body: Container(
              decoration: _getBackgroundGradient(displayName),
              child: RefreshIndicator(
                onRefresh: () => provider.refresh(),
                color: _getPrimaryColor(displayName),
                backgroundColor: Colors.white,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenHeight = constraints.maxHeight;
                    final isCompact = screenHeight < 700;
                    
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: screenHeight),
                        child: Column(
                          children: [
                            // 상단 헤더 공간 줄임 (앱바 뒤)
                            SizedBox(height: isCompact ? 50 : 55),
                            
                            // 카드 리스트 (간격 최적화)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isCompact ? 12.0 : 16.0,
                              ),
                              child: Column(
                                children: [
                                  VerseCard(
                                    title: '지난주 말씀',
                                    weekType: WeekType.last,
                                    sheetName: sheetName,
                                    provider: provider,
                                  ),
                                  VerseCard(
                                    title: '이번주 말씀',
                                    weekType: WeekType.current,
                                    sheetName: sheetName,
                                    provider: provider,
                                  ),
                                  VerseCard(
                                    title: '다음주 말씀',
                                    weekType: WeekType.next,
                                    sheetName: sheetName,
                                    provider: provider,
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: isCompact ? 20 : 30),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        );
      },
    );
  }
  
  // 타이틀 섹션 빌더
  Widget _buildTitleSection(BuildContext context, String displayName, bool isCompact) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isCompact ? 20 : 32),
      padding: EdgeInsets.all(isCompact ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _getPrimaryColor(displayName).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getPrimaryColor(displayName).withOpacity(0.1),
                  _getPrimaryColor(displayName).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              _getIconForDisplayName(displayName),
              size: isCompact ? 32 : 40,
              color: _getPrimaryColor(displayName),
            ),
          ),
          SizedBox(height: isCompact ? 12 : 16),
          Text(
            '$displayName 암송구절',
            style: TextStyle(
              fontSize: isCompact ? 22 : 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2937),
              letterSpacing: -0.02,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isCompact ? 6 : 8),
          Text(
            '주님의 말씀으로 마음을 채워요',
            style: TextStyle(
              fontSize: isCompact ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
              letterSpacing: -0.01,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // 애니메이션 카드 래퍼
  Widget _buildAnimatedCard({required Widget child, required int delay}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  // 로딩 상태 UI
  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC), // slate-50
              Color(0xFFF1F5F9), // slate-100
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '말씀을 불러오는 중...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '잠시만 기다려주세요',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 에러 상태 UI
  Widget _buildErrorState(BuildContext context, VerseProvider provider) {
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    size: 64,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '문제가 발생했어요',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 12),
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
                  onPressed: () => provider.refresh(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('다시 시도'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
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
  
  // 헤더 그라데이션
  BoxDecoration _getHeaderGradient(String displayName) {
    switch (displayName) {
      case '유치부':
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8B5CF6), // violet-500
              Color(0xFFA855F7), // purple-500
            ],
          ),
        );
      case '초등부':
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1), // indigo-500
              Color(0xFF3B82F6), // blue-500
            ],
          ),
        );
      case '중고등부':
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF10B981), // emerald-500
              Color(0xFF059669), // emerald-600
            ],
          ),
        );
      default:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
            ],
          ),
        );
    }
  }
  
  // 배경 그라데이션
  BoxDecoration _getBackgroundGradient(String displayName) {
    switch (displayName) {
      case '유치부':
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3E8FF), // violet-50
              Color(0xFFFAF5FF), // purple-25
              Color(0xFFFFFBFF), // almost white
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        );
      case '초등부':
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEEF2FF), // indigo-50
              Color(0xFFEFF6FF), // blue-25
              Color(0xFFFFFBFF), // almost white
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        );
      case '중고등부':
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFECFDF5), // emerald-50
              Color(0xFFF0FDF4), // green-25
              Color(0xFFFFFBFF), // almost white
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        );
      default:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFFFFFFF),
            ],
          ),
        );
    }
  }
  
  // 아이콘 선택
  IconData _getIconForDisplayName(String displayName) {
    switch (displayName) {
      case '유치부':
        return Icons.child_care_rounded;
      case '초등부':
        return Icons.school_rounded;
      case '중고등부':
        return Icons.groups_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }
  
  // 프라이머리 색상
  Color _getPrimaryColor(String displayName) {
    switch (displayName) {
      case '유치부':
        return const Color(0xFF8B5CF6); // violet-500
      case '초등부':
        return const Color(0xFF6366F1); // indigo-500
      case '중고등부':
        return const Color(0xFF10B981); // emerald-500
      default:
        return const Color(0xFF6366F1);
    }
  }
} 