import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edvoyage/_env/env.dart';
import 'package:edvoyage/utils/api_response_handler.dart';

class NotesApiService {
  static const String baseUrl = '${BaseUrl.baseUrl}/notes';

  /// Fetch video lectures for a specific category
  static Future<List<Map<String, dynamic>>> fetchVideoLectures({
    required int topicId,
  }) async {
    final url = '$baseUrl/topics/$topicId/video-lectures/';
    print('🔍 DEBUG: Fetching video lectures from: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔍 DEBUG: API Response Status: ${response.statusCode}');
      print('🔍 DEBUG: API Response Headers: ${response.headers}');
      print('🔍 DEBUG: API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Use standardized response handler
        final data = ApiResponseHandler.parseListResponse(
          response.body,
          (json) => json,
        );
        print('✅ Successfully fetched video lectures from API');
        print('📊 Number of lectures: ${data.length}');
        return data;
      } else if (response.statusCode == 404) {
        print('❌ Topic not found: $topicId');
        throw Exception('Topic not found: $topicId');
      } else {
        print('❌ API request failed with status: ${response.statusCode}');
        print('❌ Error response: ${response.body}');
        throw Exception(
            'Failed to load video lectures: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching video lectures from API: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Fetch categories with statistics
  static Future<Map<String, dynamic>> fetchCategories() async {
    final url = '$baseUrl/categories/';
    print('🔍 DEBUG: Fetching categories from: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔍 DEBUG: Categories API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Use standardized response handler
        final responseData = ApiResponseHandler.parseResponse(
          response.body,
          (data) => data as Map<String, dynamic>,
        );

        if (responseData.isSuccess && responseData.data != null) {
          print('✅ Successfully fetched categories from API');
          return responseData.data!;
        } else {
          print(
              '❌ Categories API Response structure unexpected: ${response.body}');
          throw Exception('Invalid categories response structure');
        }
      } else {
        print(
            '❌ Categories API request failed with status: ${response.statusCode}');
        print('❌ Error response: ${response.body}');
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching categories: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Track video view for analytics
  static Future<void> trackVideoView(int moduleId) async {
    final url = '$baseUrl/track/view/';
    print('🔍 DEBUG: Tracking video view at: $url for module: $moduleId');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'module_id': moduleId,
        }),
      );

      print('🔍 DEBUG: Track view API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Video view tracked successfully');
      } else {
        print('⚠️ Failed to track video view: ${response.statusCode}');
        print('⚠️ Error response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error tracking video view: $e');
    }
  }

  /// Test API connectivity
  static Future<bool> testApiConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔍 DEBUG: API Connection Test - Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ API Connection Test Failed: $e');
      return false;
    }
  }
}
