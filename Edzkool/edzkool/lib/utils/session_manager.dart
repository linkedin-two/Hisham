import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists session credentials in encrypted storage (Keychain / Keystore).
class SessionManager {
  SessionManager._();

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _emailKey = 'user_email';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userRoleKey = 'user_role';
  static const String _migrationKey = 'secure_storage_migrated';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    webOptions: WebOptions(
      dbName: 'edzkool_secure_storage',
      publicKey: 'edzkool_web_v1',
    ),
  );

  static Future<void> _migrateFromSharedPreferencesIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationKey) == true) return;

    final legacyToken = prefs.getString('token');
    final legacyEmail = prefs.getString(_emailKey);
    final legacyLoggedIn = prefs.getBool(_isLoggedInKey);

    if (legacyToken != null && legacyToken.isNotEmpty) {
      await _secureStorage.write(key: _tokenKey, value: legacyToken);
      await prefs.remove('token');
    }
    if (legacyEmail != null && legacyEmail.isNotEmpty) {
      await _secureStorage.write(key: _emailKey, value: legacyEmail);
    }
    if (legacyLoggedIn != null) {
      await _secureStorage.write(
        key: _isLoggedInKey,
        value: legacyLoggedIn.toString(),
      );
    }

    await prefs.setBool(_migrationKey, true);
  }

  static Future<void> storeToken(String token) async {
    await _migrateFromSharedPreferencesIfNeeded();
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getStoredToken() async {
    await _migrateFromSharedPreferencesIfNeeded();
    return _secureStorage.read(key: _tokenKey);
  }

  static Future<void> storeRefreshToken(String token) async {
    await _migrateFromSharedPreferencesIfNeeded();
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    await _migrateFromSharedPreferencesIfNeeded();
    return _secureStorage.read(key: _refreshTokenKey);
  }

  static Future<void> storeUserEmail(String email) async {
    await _migrateFromSharedPreferencesIfNeeded();
    await _secureStorage.write(key: _emailKey, value: email);
  }

  static Future<String?> getUserEmail() async {
    await _migrateFromSharedPreferencesIfNeeded();
    return _secureStorage.read(key: _emailKey);
  }

  static Future<void> storeUserRole(String role) async {
    await _migrateFromSharedPreferencesIfNeeded();
    await _secureStorage.write(key: _userRoleKey, value: role);
  }

  static Future<String?> getUserRole() async {
    await _migrateFromSharedPreferencesIfNeeded();
    return _secureStorage.read(key: _userRoleKey);
  }

  static Future<void> setLoginState(bool isLoggedIn) async {
    await _migrateFromSharedPreferencesIfNeeded();
    await _secureStorage.write(
      key: _isLoggedInKey,
      value: isLoggedIn.toString(),
    );
  }

  static Future<bool> isLoggedIn() async {
    await _migrateFromSharedPreferencesIfNeeded();
    final value = await _secureStorage.read(key: _isLoggedInKey);
    return value == 'true';
  }

  static Future<void> clearSession() async {
    await _migrateFromSharedPreferencesIfNeeded();
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _isLoggedInKey);
    await _secureStorage.delete(key: _userRoleKey);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove(_emailKey);
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userRoleKey);
  }

  static Future<void> clearToken() async {
    await _migrateFromSharedPreferencesIfNeeded();
    await _secureStorage.delete(key: _tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
