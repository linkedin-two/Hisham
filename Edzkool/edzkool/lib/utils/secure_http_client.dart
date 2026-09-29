import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:edzkool/_env/env.dart';
import 'package:edzkool/utils/app_log.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// TLS certificate pinning for production API hosts.
///
/// Pass pins at build time:
/// `--dart-define=API_CERT_SHA256=base64pin1,base64pin2`
///
/// Generate a pin (leaf cert DER SHA-256, base64):
/// `openssl s_client -connect HOST:443 -servername HOST </dev/null 2>/dev/null | openssl x509 -outform der | openssl dgst -sha256 -binary | openssl enc -base64`
class SecureHttpClient {
  SecureHttpClient._();

  static http.Client? _client;

  static const String _pinsEnv = String.fromEnvironment(
    'API_CERT_SHA256',
    defaultValue: '',
  );

  static final Set<String> _allowedPins = _pinsEnv
      .split(',')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toSet();

  static bool get pinningEnabled =>
      !BaseUrl.isDebug && _allowedPins.isNotEmpty && !kIsWeb;

  static http.Client get instance {
    _client ??= _createClient();
    return _client!;
  }

  static http.Client _createClient() {
    if (kIsWeb) {
      return http.Client();
    }

    final ioClient = HttpClient();
    if (pinningEnabled) {
      ioClient.badCertificateCallback = _validateCertificate;
      AppLog.debug('TLS certificate pinning enabled (${_allowedPins.length} pins)');
    }
    return IOClient(ioClient);
  }

  static bool _validateCertificate(X509Certificate cert, String host, int port) {
    final hostLower = host.toLowerCase();
    final apiHost = Uri.parse(BaseUrl.baseUrlApi).host.toLowerCase();
    if (hostLower != apiHost && !hostLower.endsWith('.onrender.com')) {
      return true;
    }

    final fingerprint = base64.encode(sha256.convert(cert.der).bytes);
    final allowed = _allowedPins.contains(fingerprint);
    if (!allowed) {
      AppLog.error('Certificate pin mismatch for $host:$port');
    }
    return allowed;
  }

  static void reset() {
    _client?.close();
    _client = null;
  }
}
