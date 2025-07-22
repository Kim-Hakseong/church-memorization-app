import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;

class ScreenshotService {
  static final Map<String, GlobalKey> _repaintBoundaryKeys = {};

  static GlobalKey getRepaintBoundaryKey(String screenId) {
    _repaintBoundaryKeys[screenId] ??= GlobalKey();
    return _repaintBoundaryKeys[screenId]!;
  }

  /// 스크린샷을 찍고 웹에서 다운로드하는 함수
  static Future<void> captureAndDownload(String ageGroupName) async {
    try {
      // RepaintBoundary를 통한 스크린샷 캡처
      final key = _repaintBoundaryKeys[ageGroupName];
      if (key == null || key.currentContext == null) {
        throw Exception('스크린샷을 찍을 수 없습니다. 화면이 준비되지 않았습니다.');
      }
      
      final RenderRepaintBoundary boundary = 
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List? imageBytes = byteData?.buffer.asUint8List();

      if (imageBytes != null) {
        // 파일명 생성 (날짜 + 연령부명)
        final String timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
        final String filename = '교회학교_${ageGroupName}_암송구절_$timestamp.png';

        // 웹에서 파일 다운로드
        await _downloadFile(imageBytes, filename);

        debugPrint('스크린샷 저장 완료: $filename');
      } else {
        throw Exception('스크린샷 캡처에 실패했습니다.');
      }
    } catch (e) {
      debugPrint('스크린샷 저장 중 오류: $e');
      rethrow;
    }
  }

  /// 웹에서 파일을 다운로드하는 함수
  static Future<void> _downloadFile(Uint8List bytes, String filename) async {
    if (kIsWeb) {
      // 웹 환경에서 파일 다운로드
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // 다운로드 링크 생성 및 클릭
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      
      // 메모리 정리
      html.Url.revokeObjectUrl(url);
    } else {
      // 모바일/데스크톱 환경 (추후 확장 가능)
      debugPrint('모바일/데스크톱 환경에서는 아직 지원되지 않습니다.');
    }
  }

  /// 스크린샷 가능 여부 확인
  static bool isScreenshotSupported() {
    return kIsWeb; // 현재는 웹만 지원
  }
} 