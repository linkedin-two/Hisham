import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:edzkool/utils/authenticated_http.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../_env/chat_env.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatApiService {
  final String currentUserEmail;
  final String? authToken;

  ChatApiService({required this.currentUserEmail, this.authToken});

  void _ensureAuth() {
    if (authToken == null || authToken!.trim().isEmpty) {
      throw Exception('Authentication token missing. Please sign in again.');
    }
    if (currentUserEmail.trim().isEmpty) {
      throw Exception('User email not set. Please sign in again.');
    }
  }

  bool _isSuccess(dynamic status) => status == true || status == 1;

  String? _lookupMime(String filename) {
    final n = filename.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.jpg') || n.endsWith('.jpeg')) return 'image/jpeg';
    if (n.endsWith('.gif')) return 'image/gif';
    if (n.endsWith('.webp')) return 'image/webp';
    return null;
  }

  Future<void> _attachImage(http.MultipartRequest request, XFile image) async {
    final mime = _lookupMime(kIsWeb ? image.name : image.path) ?? 'image/jpeg';
    final parts = mime.split('/');

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: image.name.isNotEmpty ? image.name : 'image.jpg',
          contentType: MediaType(parts[0], parts[1]),
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          filename: image.path.split(Platform.pathSeparator).last,
          contentType: MediaType(parts[0], parts[1]),
        ),
      );
    }
  }

  Future<http.Response> _authorizedGet(Uri url) async {
    return AuthenticatedHttp.get(url);
  }

  Future<http.Response> _sendMultipart(http.MultipartRequest request) async {
    return AuthenticatedHttp.sendMultipart(request);
  }

  Future<List<Conversation>> getConversations() async {
    _ensureAuth();
    final url = Uri.parse(ChatApi.conversations);

    final response = await _authorizedGet(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (_isSuccess(data['status'])) {
        return (data['conversations'] as List? ?? [])
            .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(data['error'] ?? 'Failed to load conversations');
    }
    throw Exception('Failed to load conversations: ${response.statusCode}');
  }

  Future<List<Message>> getMessages(String otherEmail) async {
    _ensureAuth();
    final url = Uri.parse(
      '${ChatApi.messages}?other_email=${Uri.encodeComponent(otherEmail)}',
    );

    final response = await _authorizedGet(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (_isSuccess(data['status'])) {
        return (data['messages'] as List? ?? [])
            .map((e) => Message.fromJson(e as Map<String, dynamic>, currentUserEmail))
            .toList();
      }
      throw Exception(data['error'] ?? 'Failed to load messages');
    }
    throw Exception('Failed to load messages: ${response.statusCode}');
  }

  Future<Message> sendMessage({
    required String toEmail,
    String? text,
    XFile? image,
  }) async {
    _ensureAuth();
    final url = Uri.parse(ChatApi.send);
    final request = await AuthenticatedHttp.multipartPost(
      url,
      fields: {
        'to_email': toEmail,
        if (text != null && text.isNotEmpty) 'text': text,
      },
    );

    if (image != null) {
      await _attachImage(request, image);
    }

    final response = await _sendMultipart(request);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (_isSuccess(data['status'])) {
        return Message.fromJson(
          data['message'] as Map<String, dynamic>,
          currentUserEmail,
        );
      }
      throw Exception(data['error'] ?? 'Failed to send message');
    }
    throw Exception('Failed to send message: ${response.statusCode}');
  }

  Future<List<UserSimple>> getAllUsers() async {
    _ensureAuth();
    final url = Uri.parse(ChatApi.users);

    final response = await _authorizedGet(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (_isSuccess(data['status'])) {
        return (data['users'] as List? ?? [])
            .map((e) => UserSimple.fromJson(e as Map<String, dynamic>))
            .where((u) => u.email != currentUserEmail)
            .toList();
      }
      throw Exception(data['error'] ?? 'Failed to load users');
    }
    throw Exception('Failed to load users: ${response.statusCode}');
  }
}
