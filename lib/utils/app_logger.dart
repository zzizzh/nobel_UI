import 'package:logger/logger.dart';

class AppLogger {
  // 싱글톤 인스턴스
  static final Logger _logger = Logger();

  // 인스턴스 반환 메서드
  static Logger get instance => _logger;
}