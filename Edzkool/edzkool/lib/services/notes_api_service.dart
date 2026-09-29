import 'package:edzkool/utils/app_log.dart';
import 'dart:convert';
import 'package:edzkool/_env/env.dart';
import 'package:edzkool/utils/api_response_handler.dart';
import 'package:edzkool/utils/authenticated_http.dart';

class NotesApiService {
  static const String baseUrl = '${BaseUrl.baseUrl}/notes';

  /// Fetch video lectures for a specific category
  static Future<List<Map<String, dynamic>>> fetchVideoLectures({
    required int topicId,
  }) async {
    final url = '$baseUrl/topics/$topicId/video-lectures/';
    AppLog.debug('🔍 DEBUG: Fetching video lectures from: $url');

    try {
      final response = await AuthenticatedHttp.get(Uri.parse(url));

      AppLog.debug('🔍 DEBUG: API Response Status: ${response.statusCode}');
      AppLog.debug('🔍 DEBUG: API Response Headers: ${response.headers}');
      AppLog.debug('🔍 DEBUG: API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = ApiResponseHandler.parseListResponse(
          response.body,
          (json) => json,
        );
        AppLog.debug('✅ Successfully fetched video lectures from API');
        AppLog.debug('📊 Number of lectures: ${data.length}');
        return data;
      } else if (response.statusCode == 404) {
        AppLog.debug('❌ Topic not found: $topicId');
        throw Exception('Topic not found: $topicId');
      } else {
        AppLog.debug('❌ API request failed with status: ${response.statusCode}');
        AppLog.debug('❌ Error response: ${response.body}');
        throw Exception(
            'Failed to load video lectures: ${response.statusCode}');
      }
    } catch (e) {
      AppLog.debug('❌ Error fetching video lectures from API: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Fetch categories with statistics
  static Future<Map<String, dynamic>> fetchCategories() async {
    final url = '$baseUrl/categories/';
    AppLog.debug('🔍 DEBUG: Fetching categories from: $url');

    try {
      final response = await AuthenticatedHttp.get(Uri.parse(url));

      AppLog.debug('🔍 DEBUG: Categories API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = ApiResponseHandler.parseResponse(
          response.body,
          (data) => data as Map<String, dynamic>,
        );

        if (responseData.isSuccess && responseData.data != null) {
          AppLog.debug('✅ Successfully fetched categories from API');
          return responseData.data!;
        } else {
          AppLog.debug(
              '❌ Categories API Response structure unexpected: ${response.body}');
          throw Exception('Invalid categories response structure');
        }
      } else {
        AppLog.debug(
            '❌ Categories API request failed with status: ${response.statusCode}');
        AppLog.debug('❌ Error response: ${response.body}');
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      AppLog.debug('❌ Error fetching categories: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Track video view for analytics
  static Future<void> trackVideoView(int moduleId) async {
    final url = '$baseUrl/track/view/';
    AppLog.debug('🔍 DEBUG: Tracking video view at: $url for module: $moduleId');

    try {
      final response = await AuthenticatedHttp.post(
        Uri.parse(url),
        body: json.encode({
          'module_id': moduleId,
        }),
      );

      AppLog.debug('🔍 DEBUG: Track view API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        AppLog.debug('✅ Video view tracked successfully');
      } else {
        AppLog.debug('⚠️ Failed to track video view: ${response.statusCode}');
        AppLog.debug('⚠️ Error response: ${response.body}');
      }
    } catch (e) {
      AppLog.debug('❌ Error tracking video view: $e');
    }
  }

  /// Test API connectivity
  static Future<bool> testApiConnection() async {
    try {
      final response = await AuthenticatedHttp.get(
        Uri.parse('$baseUrl/categories/'),
      );

      AppLog.debug('🔍 DEBUG: API Connection Test - Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      AppLog.debug('❌ API Connection Test Failed: $e');
      return false;
    }
  }
}
