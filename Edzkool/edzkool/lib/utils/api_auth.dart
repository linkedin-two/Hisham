import 'package:edzkool/utils/session_manager.dart';

/// Builds standard API headers including JWT when available.
class ApiAuth {
  ApiAuth._();

  static Future<Map<String, String>> headers({
    bool json = true,
    Map<String, String>? extra,
  }) async {
    final token = await SessionManager.getStoredToken();
    final result = <String, String>{
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...?extra,
    };
    return result;
  }
}
