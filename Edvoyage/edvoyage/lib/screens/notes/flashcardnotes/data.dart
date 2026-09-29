import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edvoyage/_env/notes_env.dart';

Future<dynamic> fetchFlashcards() async {
  final url = Uri.parse('${BaseUrl.baseUrl}/notes/flashcards/');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Full JSON Response:\n$data');
      return data;
    } else {
      print('❌ Failed to fetch data: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    print('⚠️ Error fetching flashcards: $e');
  }
}
