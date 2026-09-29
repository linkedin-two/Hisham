import 'package:edzkool/_env/env.dart';

class ChatApi {
  static const String baseUrl = BaseUrl.baseUrlApi;

  static const String conversations = '$baseUrl/api/conversations';
  static const String conversationsStart = '$baseUrl/api/conversations/start';
  static const String messages = '$baseUrl/api/messages';
  static const String send = '$baseUrl/api/send';
  static const String users = '$baseUrl/api/users';
  static const String usersSearch = '$baseUrl/api/users/search';
}
