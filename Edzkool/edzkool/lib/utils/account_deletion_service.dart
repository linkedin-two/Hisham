import 'dart:convert';

import 'package:edzkool/_env/env.dart';
import 'package:edzkool/utils/app_log.dart';
import 'package:edzkool/utils/authenticated_http.dart';
import 'package:edzkool/utils/token_auth_service.dart';

/// GDPR-style account deletion — deactivates account and clears local session.
class AccountDeletionService {
  AccountDeletionService._();

  static String get _deleteUrl => '${BaseUrl.baseUrl}/users/delete-account/';

  static Future<bool> deleteAccount({required String confirmEmail}) async {
    try {
      final response = await AuthenticatedHttp.delete(
        Uri.parse(_deleteUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await TokenAuthService.logoutAndClear();
        return true;
      }

      AppLog.warn('Account deletion failed: ${response.statusCode} ${response.body}');
      return false;
    } catch (e) {
      AppLog.error('Account deletion error', e);
      return false;
    }
  }

  static Future<bool> deleteAccountWithBody({
    required String confirmEmail,
    required String password,
  }) async {
    try {
      final response = await AuthenticatedHttp.post(
        Uri.parse(_deleteUrl),
        body: jsonEncode({
          'confirm_email': confirmEmail,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await TokenAuthService.logoutAndClear();
        return true;
      }

      AppLog.warn('Account deletion failed: ${response.statusCode} ${response.body}');
      return false;
    } catch (e) {
      AppLog.error('Account deletion error', e);
      return false;
    }
  }
}
