import 'package:edzkool/utils/api_auth.dart';
import 'package:edzkool/utils/secure_http_client.dart';
import 'package:edzkool/utils/session_manager.dart';
import 'package:edzkool/utils/token_auth_service.dart';
import 'package:http/http.dart' as http;

/// HTTP helper with TLS pinning, JWT auth, and auto-refresh on 401.
class AuthenticatedHttp {
  AuthenticatedHttp._();

  static http.Client get _client => SecureHttpClient.instance;

  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    bool json = false,
  }) async {
    return _send(
      (hdrs) => _client.get(url, headers: hdrs),
      extra: headers,
      json: json,
    );
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    bool json = true,
  }) async {
    return _send(
      (hdrs) => _client.post(url, headers: hdrs, body: body),
      extra: headers,
      json: json,
    );
  }

  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    bool json = true,
  }) async {
    return _send(
      (hdrs) => _client.put(url, headers: hdrs, body: body),
      extra: headers,
      json: json,
    );
  }

  static Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    bool json = true,
  }) async {
    return _send(
      (hdrs) => _client.patch(url, headers: hdrs, body: body),
      extra: headers,
      json: json,
    );
  }

  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    bool json = true,
  }) async {
    return _send(
      (hdrs) => _client.delete(url, headers: hdrs, body: body),
      extra: headers,
      json: json,
    );
  }

  static Future<http.Response> _send(
    Future<http.Response> Function(Map<String, String> headers) request, {
    Map<String, String>? extra,
    bool json = true,
  }) async {
    var hdrs = await ApiAuth.headers(json: json, extra: extra);
    var response = await request(hdrs);

    if (response.statusCode == 401) {
      final refreshed = await TokenAuthService.refreshAccessToken();
      if (refreshed) {
        hdrs = await ApiAuth.headers(json: json, extra: extra);
        response = await request(hdrs);
      } else {
        await SessionManager.clearSession();
      }
    }
    return response;
  }

  static Future<http.Response> sendMultipart(http.MultipartRequest request) async {
    request.headers.addAll(await ApiAuth.headers(json: false));
    var streamed = await request.send();
    var response = await http.Response.fromStream(streamed);

    if (response.statusCode == 401) {
      final refreshed = await TokenAuthService.refreshAccessToken();
      if (refreshed) {
        request.headers['Authorization'] =
            (await ApiAuth.headers(json: false))['Authorization'] ?? '';
        streamed = await request.send();
        response = await http.Response.fromStream(streamed);
      } else {
        await SessionManager.clearSession();
      }
    }
    return response;
  }

  static Future<http.MultipartRequest> multipartPost(
    Uri url, {
    Map<String, String>? fields,
  }) async {
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(await ApiAuth.headers());
    if (fields != null) {
      request.fields.addAll(fields);
    }
    return request;
  }
}
