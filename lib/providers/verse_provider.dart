import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../models/verse.dart';
import '../models/event.dart';
import '../services/verse_repository.dart';
import '../utils/date_utils.dart';

class VerseProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  final Map<String, List<Verse>> _allVerses = {};
  List<Event> _allEvents = [];
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Event> get allEvents => _allEvents;
  
  Future<void> initialize() async {
    _setLoading(true);
    _setError(null);
    
    debugPrint('🚀 VerseProvider 초기화 시작');
    
    try {
      debugPrint('📂 VerseRepository 초기화 중...');
      await VerseRepository.initialize();
      
      // 초등월암송 파싱 로직 변경으로 인한 캐시 클리어
      debugPrint('🧹 캐시 클리어 (초등월암송 파싱 로직 변경)');
      await VerseRepository.clearCache();
      
      debugPrint('📥 Excel 데이터 로드 및 캐시 중...');
      await VerseRepository.loadAndCacheData();
      
      debugPrint('🔄 데이터 로딩 중...');
      await _loadData();
      
      debugPrint('✅ 초기화 완료!');
    } catch (e) {
      debugPrint('❌ 초기화 오류: $e');
      _setError('데이터를 불러오는 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _loadData() async {
    try {
      // Load verses for each sheet
      final sheets = ['유치부', '초등부', '중고등부', '초등월암송'];
      debugPrint('🔄 Provider에서 시트 데이터 로딩 시작');
      for (String sheet in sheets) {
        final verses = VerseRepository.getVersesForSheet(sheet);
        _allVerses[sheet] = verses;
        debugPrint('📚 $sheet: ${verses.length}개 구절 로드됨');
        if (verses.isNotEmpty) {
          debugPrint('   첫 번째 구절: ${verses.first.text.substring(0, math.min(30, verses.first.text.length))}...');
        }
      }
      
      // Load events
      _allEvents = VerseRepository.getAllEvents();
      
      // Don't call notifyListeners here as it will be called by _setLoading(false)
    } catch (e) {
      _setError('데이터 로딩 중 오류: $e');
    }
  }
  
  List<Verse> getVersesForSheet(String sheetName) {
    return _allVerses[sheetName] ?? [];
  }
  
  Verse? getVerseForWeek(String sheetName, WeekType weekType) {
    final verses = getVersesForSheet(sheetName);
    if (verses.isEmpty) return null;
    
    final now = DateTime.now();
    
    // First try to find exact week matches
    for (Verse verse in verses) {
      switch (weekType) {
        case WeekType.last:
          if (DateUtils.isLastWeek(verse.date, now)) {
            return verse;
          }
          break;
        case WeekType.current:
          if (DateUtils.isThisWeek(verse.date, now)) {
            return verse;
          }
          break;
        case WeekType.next:
          if (DateUtils.isNextWeek(verse.date, now)) {
            return verse;
          }
          break;
      }
    }
    
    // If no exact match found, use week-of-year logic to cycle through verses
    final currentWeekOfYear = DateUtils.getWeekOfYear(now);
    final versesCount = verses.length;
    
    if (versesCount == 0) return null;
    
    int targetWeekOffset = 0;
    switch (weekType) {
      case WeekType.last:
        targetWeekOffset = -1;
        break;
      case WeekType.current:
        targetWeekOffset = 0;
        break;
      case WeekType.next:
        targetWeekOffset = 1;
        break;
    }
    
    final targetWeek = currentWeekOfYear + targetWeekOffset;
    final verseIndex = (targetWeek - 1) % versesCount;
    final adjustedIndex = verseIndex < 0 ? versesCount + verseIndex : verseIndex;
    
    return verses[adjustedIndex];
  }
  
  List<Event> getEventsForDate(DateTime date) {
    return _allEvents.where((event) {
      return event.date.year == date.year &&
             event.date.month == date.month &&
             event.date.day == date.day;
    }).toList();
  }
  
  /// 현재 월에 해당하는 월암송 구절을 가져옴
  Verse? getVerseForCurrentMonth() {
    final monthlyVerses = getVersesForSheet('초등월암송');
    if (monthlyVerses.isEmpty) {
      debugPrint('🚨 초등월암송 시트가 비어있습니다');
      return null;
    }
    
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    
    debugPrint('🌟 현재 날짜: $currentYear년 $currentMonth월');
    debugPrint('📅 찾는 월: $currentMonth월, 월암송 개수: ${monthlyVerses.length}개');
    
    // 현재 월과 정확히 일치하는 구절 찾기
    for (Verse verse in monthlyVerses) {
      if (verse.date.month == currentMonth) {
        debugPrint('✅ $currentMonth월 월암송 찾음: ${verse.text.substring(0, math.min(30, verse.text.length))}...');
        return verse;
      }
    }
    
    debugPrint('❌ $currentMonth월 월암송을 찾을 수 없습니다');
    debugPrint('📊 사용 가능한 월암송들:');
    for (int i = 0; i < monthlyVerses.length; i++) {
      final verse = monthlyVerses[i];
      debugPrint('  - ${verse.date.month}월: ${verse.text.substring(0, math.min(20, verse.text.length))}...');
    }
    
    return null;
  }
  
  Future<void> refresh() async {
    await VerseRepository.clearCache();
    await initialize();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}

enum WeekType { last, current, next }
