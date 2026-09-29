import 'package:flutter/foundation.dart';

/// Debug-only logging. Never logs in release builds.
class AppLog {
  AppLog._();

  static void debug(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print(message);
    }
  }

  static void warn(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[WARN] $message');
    }
  }

  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[ERROR] $message${error != null ? ': $error' : ''}');
    }
  }
}
