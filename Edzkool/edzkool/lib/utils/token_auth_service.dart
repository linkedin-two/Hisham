import 'dart:convert';

import 'package:edzkool/_env/env.dart';
import 'package:edzkool/utils/app_log.dart';
import 'package:edzkool/utils/secure_http_client.dart';
import 'package:edzkool/utils/session_manager.dart';
import 'package:http/http.dart' as http;

/// JWT token refresh and server-side logout.
/// Uses pinned HTTP client directly (no auth-retry loop on refresh endpoint).
class TokenAuthService {
  TokenAuthService._();

  static http.Client get _client => SecureHttpClient.instance;

  static Future<bool> refreshAccessToken() async {
    final refresh = await SessionManager.getRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      return false;
    }

    try {
      final response = await _client.post(
        Uri.parse(BaseUrl.tokenRefresh),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refresh': refresh}),
      );

      if (response.statusCode != 200) {
        AppLog.warn('Token refresh failed: ${response.statusCode}');
        return false;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final access = json['access'] as String?;
      if (access == null || access.isEmpty) {
        return false;
      }

      await SessionManager.storeToken(access);
      final newRefresh = json['refresh'] as String?;
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await SessionManager.storeRefreshToken(newRefresh);
      }
      return true;
    } catch (e) {
      AppLog.error('Token refresh error', e);
      return false;
    }
  }

  static Future<void> logoutOnServer() async {
    final refresh = await SessionManager.getRefreshToken();
    final access = await SessionManager.getStoredToken();
    if (refresh == null && access == null) return;

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (access != null && access.isNotEmpty)
          'Authorization': 'Bearer $access',
      };
      await _client.post(
        Uri.parse(BaseUrl.logout),
        headers: headers,
        body: jsonEncode({
          if (refresh != null && refresh.isNotEmpty) 'refresh_token': refresh,
        }),
      );
    } catch (e) {
      AppLog.error('Server logout failed', e);
    }
  }

  static Future<void> logoutAndClear() async {
    await logoutOnServer();
    await SessionManager.clearSession();
  }
}
