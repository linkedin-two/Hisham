import 'package:edzkool/utils/authenticated_http.dart';
import 'dart:convert';
import 'package:edzkool/utils/app_log.dart';
import 'package:edzkool/utils/session_manager.dart';
import 'package:edzkool/_env/notes_env.dart';

Future<dynamic> fetchFlashcards() async {
  final token = await SessionManager.getStoredToken();
  if (token == null || token.isEmpty) {
    AppLog.debug('Skipping flashcards fetch — not authenticated');
    return null;
  }

  final url = Uri.parse('${BaseUrl.baseUrl}/notes/flashcards/');

  try {
    final response = await AuthenticatedHttp.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['data'] != null) {
        return decoded['data'];
      }
      return decoded;
    }

    if (response.statusCode == 401) {
      AppLog.debug('Flashcards fetch unauthorized — login required');
      return null;
    }

    AppLog.debug('Failed to fetch flashcards: ${response.statusCode}');
    return null;
  } catch (e) {
    AppLog.debug('Error fetching flashcards: $e');
    return null;
  }
}
