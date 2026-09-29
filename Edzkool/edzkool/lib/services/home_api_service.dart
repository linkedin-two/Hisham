import 'dart:convert';

import 'package:edzkool/_env/env.dart';
import 'package:edzkool/utils/authenticated_http.dart';
import 'package:edzkool/utils/api_response_handler.dart';
import 'package:intl/intl.dart';

/// Aggregates home dashboard data from real backend endpoints (replaces legacy /auth/home).
class HomeApiService {
  HomeApiService._();

  static Future<Map<String, dynamic>?> fetchDashboard() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final results = await Future.wait([
        AuthenticatedHttp.get(
          Uri.parse('${BaseUrl.mcqQuestionOfTheDay}?date=$today'),
          json: false,
        ),
        AuthenticatedHttp.get(Uri.parse(BaseUrl.notificationsList)),
        AuthenticatedHttp.get(Uri.parse(BaseUrl.notificationsOffers)),
      ]);

      final mcqResponse = results[0];
      final allNotificationsResponse = results[1];
      final offerNotificationsResponse = results[2];

      Map<String, dynamic> questionOfTheDay = {};
      if (mcqResponse.statusCode == 200) {
        final decoded = jsonDecode(mcqResponse.body);
        if (decoded is Map && decoded['data'] != null) {
          questionOfTheDay = Map<String, dynamic>.from(decoded['data'] as Map);
        } else if (decoded is Map) {
          questionOfTheDay = Map<String, dynamic>.from(decoded);
        } else if (decoded is List && decoded.isNotEmpty) {
          questionOfTheDay = Map<String, dynamic>.from(
            decoded.first as Map,
          );
        }
      }

      List<dynamic> allNotifications = [];
      if (allNotificationsResponse.statusCode == 200) {
        final envelope = ApiResponseHandler.parseResponse(
          allNotificationsResponse.body,
          (data) => data,
        );
        if (envelope.isSuccess) {
          allNotifications = ApiResponse.extractList(envelope.data);
        }
      }

      List<dynamic> offerNotifications = [];
      if (offerNotificationsResponse.statusCode == 200) {
        final envelope = ApiResponseHandler.parseResponse(
          offerNotificationsResponse.body,
          (data) => data,
        );
        if (envelope.isSuccess) {
          offerNotifications = ApiResponse.extractList(envelope.data);
        }
      }

      return {
        'question_of_the_day': questionOfTheDay,
        'all_notifications': allNotifications,
        'offer_notifications': offerNotifications,
      };
    } catch (_) {
      return null;
    }
  }
}
