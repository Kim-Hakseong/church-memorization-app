import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/verse_provider.dart';

class MonthlyVerseScreen extends StatelessWidget {
  const MonthlyVerseScreen({super.key});

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
            title: const Text(
              '초등월암송',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.02,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667EEA), // custom blue
                    Color(0xFF764BA2), // custom purple
                  ],
                ),
              ),
            ),
          ),
          extendBodyBehindAppBar: true,
          body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF667EEA), // custom blue
                    Color(0xFF764BA2), // custom purple  
                    Color(0xFFF093FB), // light pink
                    Color(0xFFF5F7FA), // almost white
                  ],
                  stops: [0.0, 0.4, 0.7, 1.0],
                ),
              ),
              child: RefreshIndicator(
                onRefresh: () => provider.refresh(),
                color: const Color(0xFF667EEA),
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                      children: [
                        // 상단 헤더 공간 (앱바 뒤)
                        const SizedBox(height: 60),
                        
                        // 월암송 카드 (헤더 제거)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: _buildMonthlyVerseCard(context, provider),
                        ),
                        
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 월암송 카드
  Widget _buildMonthlyVerseCard(BuildContext context, VerseProvider provider) {
    final monthlyVerses = provider.getVersesForSheet('초등월암송');
    final currentVerse = provider.getVerseForCurrentMonth();
    final now = DateTime.now();

    debugPrint('🔍 월암송 화면에서 확인: ${monthlyVerses.length}개 구절');
    debugPrint('🌟 현재 날짜: ${now.year}년 ${now.month}월 ${now.day}일');
    debugPrint('🎯 현재 월 구절 찾기 결과: ${currentVerse != null ? "찾음" : "못찾음"}');

    if (monthlyVerses.isEmpty) {
      return _buildEmptyState('아직 월암송 데이터가 없습니다', '관리자에게 문의해주세요');
    }

    if (currentVerse == null) {
      return _buildEmptyState(
        '이번 달 월암송이 없습니다',
        '${now.month}월 암송구절이 아직 준비되지 않았습니다'
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.7),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 상단 장식
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 암송구절 본문
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF667EEA).withOpacity(0.05),
                  const Color(0xFF764BA2).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // 따옴표 아이콘
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF667EEA),
                        Color(0xFF764BA2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.format_quote_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 구절 텍스트
                Text(
                  currentVerse.text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.8,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.01,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 하단 장식과 영감 문구
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667EEA).withOpacity(0.1),
                  const Color(0xFF764BA2).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: const Color(0xFF667EEA).withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '하나님의 말씀을 마음에 새겨요',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF667EEA).withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.favorite_rounded,
                  color: const Color(0xFF667EEA).withOpacity(0.7),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 빈 상태 위젯
  Widget _buildEmptyState(String title, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667EEA).withOpacity(0.1),
                  const Color(0xFF764BA2).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 48,
              color: const Color(0xFF667EEA).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              Color(0xFFF093FB),
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
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '월암송을 불러오는 중...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '잠시만 기다려주세요',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
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
} 