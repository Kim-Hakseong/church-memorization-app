import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/verse.dart';
import '../models/event.dart';

class ExcelLoader {
  static Future<Map<String, List<Verse>>> loadVerses() async {
    try {
      final ByteData data = await rootBundle.load('assets/verses.xlsx');
      final Uint8List bytes = data.buffer.asUint8List();
      final excel = Excel.decodeBytes(bytes);
      
      Map<String, List<Verse>> result = {};
      
      final allSheets = excel.tables.keys.toList();
      debugPrint('📖 Excel 파일에서 발견된 시트들: $allSheets');
      debugPrint('📊 총 ${allSheets.length}개의 시트가 있습니다');
      for (int i = 0; i < allSheets.length; i++) {
        debugPrint('  $i: "${allSheets[i]}"');
      }
      
      for (String sheetName in excel.tables.keys) {
        debugPrint('🔍 처리 중인 시트: $sheetName');
        
        final sheet = excel.tables[sheetName];
        if (sheet == null) {
          debugPrint('❌ 시트 $sheetName이 null입니다');
          continue;
        }
        
        debugPrint('📊 시트 $sheetName: ${sheet.maxRows}행');
        List<Verse> verses = [];
        
        // 초등월암송 시트는 특별 처리 (A열: 해당월, B열: 월, C열: 암송구절)
        if (sheetName == '초등월암송') {
          verses = _parseMonthlyVerses(sheet);
        } else {
          // Skip header row (row 0)
          for (int row = 1; row < sheet.maxRows; row++) {
          try {
            final lessonCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
            final verseCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row));
            final dateCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row));
            
            debugPrint('📝 행 $row - 공과: ${lessonCell.value}, 구절: ${verseCell.value}, 날짜: ${dateCell.value}');
            
            if (verseCell.value != null && dateCell.value != null) {
              final verseText = verseCell.value.toString();
              final dateValue = dateCell.value;
              
              debugPrint('  ✓ 유효한 데이터 발견: $verseText');
              
              DateTime? date;
              if (dateValue != null) {
                // Convert cell value to string and try to parse as DateTime
                final dateString = dateValue.toString();
                date = DateTime.tryParse(dateString);
                debugPrint('  📅 날짜 파싱: $dateString → $date');
              }
              
              if (date != null && verseText.isNotEmpty) {
                verses.add(Verse(
                  date: date,
                  text: verseText,
                  extra: lessonCell.value?.toString(),
                ));
                debugPrint('  ➕ 구절 추가됨!');
              } else {
                debugPrint('  ❌ 구절 추가 실패 - 날짜: $date, 텍스트 비어있음: ${verseText.isEmpty}');
              }
            } else {
              debugPrint('  ⏭️ 빈 셀 건너뜀 - 구절: ${verseCell.value}, 날짜: ${dateCell.value}');
            }
          } catch (e) {
            debugPrint('Error parsing row $row in sheet $sheetName: $e');
          }
        }
        }
        
        debugPrint('✅ 시트 $sheetName에서 ${verses.length}개의 구절을 로드했습니다');
        result[sheetName] = verses;
      }
      
      debugPrint('📋 최종 결과:');
      for (String key in result.keys) {
        debugPrint('  - $key: ${result[key]!.length}개 구절');
      }
      
      return result;
    } catch (e) {
      debugPrint('Error loading Excel file: $e');
      return {};
    }
  }

  /// 초등월암송 시트 전용 파싱 함수 (A열: 해당월, B열: 월, C열: 암송구절)
  static List<Verse> _parseMonthlyVerses(Sheet sheet) {
    List<Verse> verses = [];
    final currentYear = DateTime.now().year;
    
    debugPrint('🌟 초등월암송 시트 특별 파싱 시작 (A열: 해당월, B열: 월, C열: 암송구절)');
    
    // Skip header row (row 0)
    for (int row = 1; row < sheet.maxRows; row++) {
      try {
        final monthCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)); // A열: 해당월
        final extraCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)); // B열: 월
        final verseCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)); // C열: 암송구절
        
        debugPrint('🗓️ 행 $row - A열(해당월): ${monthCell.value}, B열(월): ${extraCell.value}, C열(암송구절): ${verseCell.value}');
        
        if (monthCell.value != null && verseCell.value != null) {
          final monthString = monthCell.value.toString().trim();
          final verseText = verseCell.value.toString().trim();
          
          if (monthString.isNotEmpty && verseText.isNotEmpty) {
            // 월 정보에서 숫자 추출 (예: "1월" -> 1, "2월" -> 2)
            final monthNumber = _extractMonthNumber(monthString);
            
            if (monthNumber != null && monthNumber >= 1 && monthNumber <= 12) {
              final date = DateTime(currentYear, monthNumber, 1); // 해당 월의 1일로 설정
              
              verses.add(Verse(
                date: date,
                text: verseText,
                extra: extraCell.value?.toString(), // B열을 extra로 저장
              ));
              
              debugPrint('  ✅ $monthNumber월 월암송 추가: ${verseText.substring(0, math.min(30, verseText.length))}...');
            } else {
              debugPrint('  ❌ 월 파싱 실패: $monthString');
            }
          }
        } else {
          debugPrint('  ⏭️ 빈 셀 건너뜀 - 해당월: ${monthCell.value}, 암송구절: ${verseCell.value}');
        }
      } catch (e) {
        debugPrint('Error parsing monthly verse row $row: $e');
      }
    }
    
    debugPrint('🌟 초등월암송 파싱 완료: ${verses.length}개 구절');
    return verses;
  }

  /// 월 문자열에서 숫자 추출 (예: "2025.7" -> 7, "2025.12" -> 12)
  static int? _extractMonthNumber(String monthString) {
    debugPrint('🔍 월 문자열 파싱 시도: "$monthString"');
    
    // "2025.7" 형식 처리 - 점(.) 뒤의 숫자 추출
    if (monthString.contains('.')) {
      final parts = monthString.split('.');
      if (parts.length >= 2) {
        final monthPart = parts[1].trim();
        final monthNumber = int.tryParse(monthPart);
        debugPrint('  ✅ 점(.) 형식에서 월 추출: $monthNumber');
        return monthNumber;
      }
    }
    
    // "2025/7" 형식 처리 - 슬래시(/) 뒤의 숫자 추출
    if (monthString.contains('/')) {
      final parts = monthString.split('/');
      if (parts.length >= 2) {
        final monthPart = parts[1].trim();
        final monthNumber = int.tryParse(monthPart);
        debugPrint('  ✅ 슬래시(/) 형식에서 월 추출: $monthNumber');
        return monthNumber;
      }
    }
    
    // "7월" 형식 처리 - 숫자 + "월"
    if (monthString.contains('월')) {
      final regex = RegExp(r'(\d+)월');
      final match = regex.firstMatch(monthString);
      if (match != null) {
        final monthNumber = int.tryParse(match.group(1)!);
        debugPrint('  ✅ "월" 형식에서 월 추출: $monthNumber');
        return monthNumber;
      }
    }
    
    // 단순 숫자만 있는 경우
    final monthNumber = int.tryParse(monthString.trim());
    if (monthNumber != null && monthNumber >= 1 && monthNumber <= 12) {
      debugPrint('  ✅ 단순 숫자에서 월 추출: $monthNumber');
      return monthNumber;
    }
    
    debugPrint('  ❌ 월 추출 실패: "$monthString"');
    return null;
  }
  
  static Future<List<Event>> loadEvents() async {
    try {
      final ByteData data = await rootBundle.load('assets/verses.xlsx');
      final Uint8List bytes = data.buffer.asUint8List();
      final excel = Excel.decodeBytes(bytes);
      
      List<Event> events = [];
      
      for (String sheetName in excel.tables.keys) {
        final sheet = excel.tables[sheetName];
        if (sheet == null) continue;
        
        // Skip header row (row 0)
        for (int row = 1; row < sheet.maxRows; row++) {
          try {
            final lessonCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
            final verseCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row));
            final dateCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row));
            
            if (lessonCell.value != null && dateCell.value != null) {
              final lessonName = lessonCell.value.toString();
              final dateValue = dateCell.value;
              
              DateTime? date;
              if (dateValue != null) {
                // Convert cell value to string and try to parse as DateTime
                final dateString = dateValue.toString();
                date = DateTime.tryParse(dateString);
              }
              
              if (date != null && lessonName.isNotEmpty) {
                events.add(Event(
                  date: date,
                  title: '$sheetName - $lessonName',
                  note: verseCell.value?.toString(),
                ));
              }
            }
          } catch (e) {
            debugPrint('Error parsing event row $row in sheet $sheetName: $e');
          }
        }
      }
      
      return events;
    } catch (e) {
      debugPrint('Error loading events: $e');
      return [];
    }
  }
}

