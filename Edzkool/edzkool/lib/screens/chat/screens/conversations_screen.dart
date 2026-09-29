import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notes/logo.dart';
import '../models/conversation_model.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';
import 'users_list_screen.dart';
import 'conversation_list_item.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _initChat();
  }

  Future<void> _initChat() async {
    await initializeChatAuth(ref);
    if (!mounted) return;
    await ref.read(conversationsProvider.notifier).loadConversations();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final currentEmail = ref.watch(currentUserEmailProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomLogoAppBar(),
      body: Column(
        children: [
          // Header with email
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF144787),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentEmail.isNotEmpty ? currentEmail : 'Messages',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey[500],
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF144787)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // Conversations list
          Expanded(
            child: conversationsAsync.when(
              data: (conversations) {
                final filtered = _searchQuery.isEmpty
                    ? conversations
                    : conversations.where((c) {
                        final query = _searchQuery.toLowerCase();
                        return c.otherEmail.toLowerCase().contains(query) ||
                               c.otherName.toLowerCase().contains(query) ||
                               c.lastText.toLowerCase().contains(query);
                      }).toList();

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(conversationsProvider.notifier).loadConversations();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final conversation = filtered[index];
                      return ConversationListItem(
                        conversation: conversation,
                        onTap: () => _openChat(conversation),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF144787),
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load conversations',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await initializeChatAuth(ref);
                        if (!mounted) return;
                        await ref.read(conversationsProvider.notifier).loadConversations();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewChat,
        backgroundColor: const Color(0xFF144787),
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to start a new chat',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          otherEmail: conversation.otherEmail,
          otherName: conversation.displayName,
        ),
      ),
    );
  }

  Future<void> _openNewChat() async {
    await initializeChatAuth(ref);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UsersListScreen(),
      ),
    );
  }
}
