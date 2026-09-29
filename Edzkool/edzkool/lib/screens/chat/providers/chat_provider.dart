import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edzkool/utils/session_manager.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/chat_api_service.dart';

final currentUserEmailProvider = StateProvider<String>((ref) => '');
final authTokenProvider = StateProvider<String?>((ref) => null);

Future<void> initializeChatAuth(WidgetRef ref) async {
  final token = await SessionManager.getStoredToken();
  final email = await SessionManager.getUserEmail();
  if (token != null && token.isNotEmpty) {
    ref.read(authTokenProvider.notifier).state = token;
  }
  if (email != null && email.isNotEmpty) {
    ref.read(currentUserEmailProvider.notifier).state = email;
  }
}

final chatApiServiceProvider = Provider<ChatApiService>((ref) {
  final email = ref.watch(currentUserEmailProvider);
  final token = ref.watch(authTokenProvider);
  return ChatApiService(currentUserEmail: email, authToken: token);
});

// Provider for conversations list with auto-refresh
final conversationsProvider = StateNotifierProvider<ConversationsNotifier, AsyncValue<List<Conversation>>>((ref) {
  final apiService = ref.watch(chatApiServiceProvider);
  return ConversationsNotifier(apiService);
});

class ConversationsNotifier extends StateNotifier<AsyncValue<List<Conversation>>> {
  final ChatApiService _apiService;
  Timer? _refreshTimer;

  ConversationsNotifier(this._apiService) : super(const AsyncValue.loading()) {
    _startAutoRefresh();
  }

  Future<void> loadConversations() async {
    try {
      state = const AsyncValue.loading();
      final conversations = await _apiService.getConversations();
      
      // Merge with all users to show new users (no messages yet)
      final users = await _apiService.getAllUsers();
      final conversationEmails = conversations.map((c) => c.otherEmail).toSet();
      
      final newUsers = users
          .where((u) => !conversationEmails.contains(u.email))
          .map((u) => Conversation(
                otherEmail: u.email,
                otherName: u.name,
                isNew: true,
              ))
          .toList();
      
      final merged = [...conversations, ...newUsers];
      state = AsyncValue.data(merged);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (state.hasValue) {
        _silentRefresh();
      }
    });
  }

  Future<void> _silentRefresh() async {
    try {
      final conversations = await _apiService.getConversations();
      final users = await _apiService.getAllUsers();
      final conversationEmails = conversations.map((c) => c.otherEmail).toSet();
      
      final newUsers = users
          .where((u) => !conversationEmails.contains(u.email))
          .map((u) => Conversation(
                otherEmail: u.email,
                otherName: u.name,
                isNew: true,
              ))
          .toList();
      
      final merged = [...conversations, ...newUsers];
      state = AsyncValue.data(merged);
    } catch (e) {
      // Silent fail on auto-refresh
    }
  }

  List<Conversation> search(String query) {
    final all = state.value ?? [];
    if (query.isEmpty) return all;
    
    final lowerQuery = query.toLowerCase();
    return all.where((c) {
      return c.otherEmail.toLowerCase().contains(lowerQuery) ||
             c.otherName.toLowerCase().contains(lowerQuery) ||
             c.lastText.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

// Provider for messages in a specific conversation
final messagesProvider = StateNotifierProvider.family<MessagesNotifier, AsyncValue<List<Message>>, String>((ref, otherEmail) {
  final apiService = ref.watch(chatApiServiceProvider);
  return MessagesNotifier(apiService, otherEmail);
});

class MessagesNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final ChatApiService _apiService;
  final String _otherEmail;
  Timer? _refreshTimer;
  String? lastSendError;

  MessagesNotifier(this._apiService, this._otherEmail) : super(const AsyncValue.loading()) {
    loadMessages();
    _startAutoRefresh();
  }

  Future<void> loadMessages({bool showLoading = true}) async {
    try {
      if (showLoading || !state.hasValue) {
        state = const AsyncValue.loading();
      }
      final messages = await _apiService.getMessages(_otherEmail);
      lastSendError = null;
      state = AsyncValue.data(messages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Returns true when the message was sent and shown in the thread.
  Future<bool> sendMessage({String? text, XFile? image}) async {
    lastSendError = null;
    try {
      final message = await _apiService.sendMessage(
        toEmail: _otherEmail,
        text: text,
        image: image,
      );

      final current = state.value ?? [];
      state = AsyncValue.data([...current, message]);
      return true;
    } catch (e) {
      lastSendError = e.toString().replaceFirst('Exception: ', '');
      // Server may have saved the message even if client parsing failed.
      await _silentRefresh();
      return false;
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!state.isLoading) {
        _silentRefresh();
      }
    });
  }

  Future<void> _silentRefresh() async {
    try {
      final messages = await _apiService.getMessages(_otherEmail);
      lastSendError = null;
      state = AsyncValue.data(messages);
    } catch (_) {
      // Keep current state on background refresh failure.
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

// Provider for all users (for new chat)
final usersProvider = FutureProvider<List<UserSimple>>((ref) async {
  final apiService = ref.watch(chatApiServiceProvider);
  return await apiService.getAllUsers();
});
