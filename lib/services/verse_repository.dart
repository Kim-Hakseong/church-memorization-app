import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/verse.dart';
import '../models/event.dart';
import 'excel_loader.dart';

class VerseRepository {
  static const String _versesBoxName = 'verses';
  static const String _eventsBoxName = 'events';
  
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_versesBoxName);
    await Hive.openBox<Map>(_eventsBoxName);
  }
  
  static Future<void> loadAndCacheData() async {
    final versesBox = Hive.box<Map>(_versesBoxName);
    final eventsBox = Hive.box<Map>(_eventsBoxName);
    
    // Check if data already exists
    if (versesBox.isNotEmpty && eventsBox.isNotEmpty) {
      debugPrint('📦 기존 캐시 데이터 사용');
      return;
    }
    
    try {
      // Load verses from Excel
      final versesData = await ExcelLoader.loadVerses();
      for (String sheetName in versesData.keys) {
        final verses = versesData[sheetName]!;
        final versesJson = verses.map((v) => v.toJson()).toList();
        await versesBox.put(sheetName, {'verses': versesJson});
      }
      
      // Load events from Excel
      final events = await ExcelLoader.loadEvents();
      final eventsJson = events.map((e) => e.toJson()).toList();
      await eventsBox.put('all_events', {'events': eventsJson});
      
    } catch (e) {
      debugPrint('Error loading and caching data: $e');
      rethrow;
    }
  }
  
  static List<Verse> getVersesForSheet(String sheetName) {
    try {
      final versesBox = Hive.box<Map>(_versesBoxName);
      final data = versesBox.get(sheetName);
      
      if (data == null || data['verses'] == null) {
        return [];
      }
      
      final List<dynamic> versesJson = data['verses'];
      return versesJson.map((json) => Verse.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      debugPrint('Error getting verses for sheet $sheetName: $e');
      return [];
    }
  }
  
  static List<Event> getAllEvents() {
    try {
      final eventsBox = Hive.box<Map>(_eventsBoxName);
      final data = eventsBox.get('all_events');
      
      if (data == null || data['events'] == null) {
        return [];
      }
      
      final List<dynamic> eventsJson = data['events'];
      return eventsJson.map((json) => Event.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      debugPrint('Error getting events: $e');
      return [];
    }
  }
  
  static Future<void> clearCache() async {
    final versesBox = Hive.box<Map>(_versesBoxName);
    final eventsBox = Hive.box<Map>(_eventsBoxName);
    
    await versesBox.clear();
    await eventsBox.clear();
  }
}
