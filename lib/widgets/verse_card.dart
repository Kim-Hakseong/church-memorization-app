import 'package:flutter/material.dart';
import '../providers/verse_provider.dart';

class VerseCard extends StatelessWidget {
  final String title;
  final WeekType weekType;
  final String sheetName;
  final VerseProvider provider;
  
  const VerseCard({
    super.key,
    required this.title,
    required this.weekType,
    required this.sheetName,
    required this.provider,
  });
  
  @override
  Widget build(BuildContext context) {
    final verse = provider.getVerseForWeek(sheetName, weekType);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenWidth < 600 || screenHeight < 800;
    final isVeryCompact = screenHeight < 700;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isCompact ? 8.0 : 12.0,
        vertical: isVeryCompact ? 2.0 : (isCompact ? 3.0 : 6.0),
      ),
      decoration: BoxDecoration(
        // Tailwind 스타일 그라데이션
        gradient: _getTailwindGradient(weekType),
        borderRadius: BorderRadius.circular(20),
        // 다층 그림자 효과 (Tailwind shadow-xl + custom)
        boxShadow: [
          BoxShadow(
            color: _getShadowColor(weekType).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: _getShadowColor(weekType).withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        // 미묘한 테두리
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 배경 패턴 오버레이
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // 메인 콘텐츠
            Padding(
              padding: EdgeInsets.all(isVeryCompact ? 14.0 : (isCompact ? 16.0 : 20.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 타이틀 뱃지
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isVeryCompact ? 8 : (isCompact ? 10 : 14), 
                          vertical: isVeryCompact ? 4 : (isCompact ? 5 : 7),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getIconForWeekType(weekType),
                              size: isVeryCompact ? 12 : (isCompact ? 13 : 15),
                              color: _getAccentColor(weekType),
                            ),
                            SizedBox(width: isCompact ? 4 : 6),
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: isVeryCompact ? 11 : (isCompact ? 12 : 14),
                                fontWeight: FontWeight.w700,
                                color: _getAccentColor(weekType),
                                letterSpacing: -0.02,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isVeryCompact ? 10 : (isCompact ? 12 : 16)),
                  
                  // 콘텐츠 영역
                  if (verse != null) ...[
                    // 공과명 (있는 경우)
                    if (verse.extra != null && verse.extra!.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 10 : 12,
                          vertical: isCompact ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getAccentColor(weekType).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          verse.extra!,
                                                  style: TextStyle(
                          fontSize: isVeryCompact ? 10 : (isCompact ? 11 : 13),
                          fontWeight: FontWeight.w600,
                          color: _getAccentColor(weekType),
                          letterSpacing: -0.01,
                        ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 12 : 16),
                    ],
                    
                    // 암송구절 본문
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isVeryCompact ? 10 : (isCompact ? 12 : 16)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        verse.text,
                        style: TextStyle(
                          fontSize: isVeryCompact ? 12 : (isCompact ? 13 : 15),
                          fontWeight: FontWeight.w500,
                          height: isVeryCompact ? 1.4 : 1.5,
                          color: const Color(0xFF1F2937), // gray-800
                          letterSpacing: -0.01,
                        ),
                        maxLines: isVeryCompact ? 3 : (isCompact ? 4 : 5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    SizedBox(height: isCompact ? 12 : 16),

                  ] else ...[
                    // 빈 상태 디자인
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isCompact ? 20 : 28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border(
                          top: BorderSide(
                            color: _getAccentColor(weekType).withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getAccentColor(weekType).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              Icons.auto_stories_rounded,
                              size: isCompact ? 28 : 36,
                              color: _getAccentColor(weekType).withOpacity(0.6),
                            ),
                          ),
                          SizedBox(height: isCompact ? 12 : 16),
                          Text(
                            '해당 주의 말씀이\n아직 준비되지 않았습니다',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isCompact ? 13 : 15,
                              fontWeight: FontWeight.w500,
                              color: _getAccentColor(weekType).withOpacity(0.7),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Tailwind CSS 인스파이어드 색상들
  Color _getAccentColor(WeekType weekType) {
    switch (weekType) {
      case WeekType.last:
        return const Color(0xFF8B5CF6); // violet-500
      case WeekType.current:
        return const Color(0xFF6366F1); // indigo-500
      case WeekType.next:
        return const Color(0xFF10B981); // emerald-500
    }
  }
  
  Color _getShadowColor(WeekType weekType) {
    switch (weekType) {
      case WeekType.last:
        return const Color(0xFF8B5CF6); // violet-500
      case WeekType.current:
        return const Color(0xFF6366F1); // indigo-500
      case WeekType.next:
        return const Color(0xFF10B981); // emerald-500
    }
  }
  
  IconData _getIconForWeekType(WeekType weekType) {
    switch (weekType) {
      case WeekType.last:
        return Icons.history_rounded;
      case WeekType.current:
        return Icons.today_rounded;
      case WeekType.next:
        return Icons.upcoming_rounded;
    }
  }
  
  LinearGradient _getTailwindGradient(WeekType weekType) {
    switch (weekType) {
      case WeekType.last:
        // Violet gradient
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3E8FF), // violet-50
            Color(0xFFE9D5FF), // violet-100
            Color(0xFFDDD6FE), // violet-200
          ],
          stops: [0.0, 0.5, 1.0],
        );
      case WeekType.current:
        // Indigo gradient
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEEF2FF), // indigo-50
            Color(0xFFE0E7FF), // indigo-100
            Color(0xFFC7D2FE), // indigo-200
          ],
          stops: [0.0, 0.5, 1.0],
        );
      case WeekType.next:
        // Emerald gradient
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFECFDF5), // emerald-50
            Color(0xFFD1FAE5), // emerald-100
            Color(0xFFA7F3D0), // emerald-200
          ],
          stops: [0.0, 0.5, 1.0],
        );
    }
  }
}
