import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  
  const SplashScreen({
    super.key,
    required this.onFinished,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500), // 페이드아웃 시간
      vsync: this,
    );
    
    // 페이드 애니메이션 설정
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // 1.5초 후 페이드아웃 시작
    _timer = Timer(const Duration(milliseconds: 1500), () {
      _startFadeOut();
    });
  }

  void _startFadeOut() {
    _animationController.forward().then((_) {
      // 페이드아웃 완료 후 메인 화면으로 이동
      widget.onFinished();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
                          child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white, // 심플한 배경색
                child: Image.asset(
                  'assets/images/splash_image.jpg',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover, // 전체 화면을 덮도록
                  errorBuilder: (context, error, stackTrace) {
                    // 이미지 로드 실패 시 에러 로그 출력
                    debugPrint('🚨 스플래시 이미지 로드 실패: $error');
                    debugPrint('📂 경로: assets/images/splash_image.jpg');
                    debugPrint('📊 스택트레이스: $stackTrace');
                    return _buildFallbackUI();
                  },
                ),
              ),
          );
        },
      ),
    );
  }

  // 이미지 로드 실패 시 표시될 대체 UI
  Widget _buildFallbackUI() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.church_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '교회학교 교육목표',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            '하나님을 경외하고\n그 명령을 지키자',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            '전도서 12:13',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
} 