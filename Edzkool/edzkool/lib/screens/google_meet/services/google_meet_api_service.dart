import 'dart:convert';

import 'package:edzkool/_env/env.dart';
import 'package:edzkool/screens/google_meet/models/google_meet_status.dart';
import 'package:edzkool/utils/api_response_handler.dart';
import 'package:edzkool/utils/authenticated_http.dart';
import 'package:http/http.dart' as http;

class GoogleMeetApiService {
  static const String _baseUrl = '${BaseUrl.baseUrl}/google-meet';

  Future<ApiResponse<GoogleMeetStatus>> getStatus() async {
    final uri = Uri.parse('$_baseUrl/status/');
    final response = await AuthenticatedHttp.get(uri, json: false);

    if (response.statusCode >= 400) {
      throw ApiResponseHandler.handleErrorResponse(
        response.body,
        response.statusCode,
      );
    }

    return ApiResponseHandler.parseResponse(
      response.body,
      (data) => GoogleMeetStatus.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<GoogleMeetStatus>> registerClass({
    required int schoolClass,
  }) async {
    final uri = Uri.parse('$_baseUrl/register-class/');
    final response = await AuthenticatedHttp.post(
      uri,
      body: jsonEncode({'school_class': schoolClass}),
    );

    if (response.statusCode >= 400) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final errors = json['errors'];
        final errorCode = errors is Map ? errors['code']?.toString() : null;

        if (errorCode == 'class_already_set') {
          return ApiResponseHandler.parseResponse(
            response.body,
            (data) => GoogleMeetStatus.fromJson(data as Map<String, dynamic>),
          );
        }
      } catch (_) {}

      throw ApiResponseHandler.handleErrorResponse(
        response.body,
        response.statusCode,
      );
    }

    return ApiResponseHandler.parseResponse(
      response.body,
      (data) => GoogleMeetStatus.fromJson(data as Map<String, dynamic>),
    );
  }
}
