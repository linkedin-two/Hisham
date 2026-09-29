import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../models/user.dart';
import '../../utils/colors/colors.dart';
import '../../screens/notes/logo.dart';
import 'chat_screen.dart';
import 'search_screen.dart';

// API Configuration - Using edzkool chat API
String get _convBaseUrl {
  return 'https://edzkool.publicvm.com/api';
}

String? _convCurrentEmail;

void _setConvCurrentEmail(String email) {
  _convCurrentEmail = email;
}

Map<String, String> get _convHeaders {
  final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
  if (_convCurrentEmail != null) {
    headers['X-User-Email'] = _convCurrentEmail!;
  }
  return headers;
}

Future<Map<String, dynamic>> _getConversations() async {
  try {
    final url = Uri.parse('$_convBaseUrl/conversations?email=${Uri.encodeComponent(_convCurrentEmail ?? '')}');
    final response = await http.get(
      url,
      headers: _convHeaders,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {'status': false, 'error': 'Server error: ${response.statusCode}'};
  } catch (e) {
    return {'status': false, 'error': e.toString()};
  }
}

class ConversationsScreen extends StatefulWidget {
  final String? userEmail;
  
  const ConversationsScreen({super.key, this.userEmail});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<dynamic> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.userEmail != null) {
      _setConvCurrentEmail(widget.userEmail!);
    }
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    try {
      final result = await _getConversations();
      if (result['status'] == true) {
        setState(() {
          _conversations = result['conversations'] ?? [];
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['error'] ?? 'Failed to load conversations';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error: $e';
      });
    }
  }

  void _openChat(String otherEmail, String otherName, String otherRole) {
    final user = User(
      email: otherEmail,
      name: otherName,
      role: otherRole,
      avatar: 'https://i.pravatar.cc/150?img=${otherEmail.hashCode % 70 + 1}',
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(user: user, currentUserEmail: widget.userEmail)),
    ).then((_) => _loadConversations());
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen(userEmail: widget.userEmail)),
    ).then((_) => _loadConversations());
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: primaryColor,
            )),
        title: SizedBox(
          height: 250, // Set the width of the container
          width: 200, // Set the height of the container
          child:
              Image.asset(edvoyagelogo1), // Replace with the actual image path
        ),
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorWidget()
                      : _conversations.isEmpty
                          ? _buildEmptyWidget()
                          : RefreshIndicator(
                              onRefresh: _loadConversations,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _conversations.length,
                                itemBuilder: (context, index) {
                                  final conv = _conversations[index];
                                  return _buildConversationTile(conv);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openSearch,
        backgroundColor: const Color(0xFF0F8A7B),
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadConversations,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _openSearch,
            child: const Text('Start a new chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(dynamic conv) {
    final otherEmail = conv['other_email'] ?? '';
    final otherName = conv['other_name'] ?? otherEmail;
    final otherAvatar = conv['other_avatar'] as String?;
    final lastText = conv['last_text'] ?? '';
    final lastTime = conv['last_time'] ?? '';
    final unread = conv['unread'] ?? 0;

    // Build avatar URL - handle both full URLs and relative paths
    String avatarUrl = '';
    if (otherAvatar != null && otherAvatar.isNotEmpty) {
      if (otherAvatar.startsWith('http')) {
        avatarUrl = otherAvatar;
      } else {
        // Django media files on edzkool server
        avatarUrl = 'https://edzkool.publicvm.com$otherAvatar';
      }
    }

    // Get display name - prioritize full name over email
    String displayName = otherName;
    if (displayName.isEmpty || displayName == otherEmail) {
      // Try to extract a better name from email or use email prefix
      displayName = otherEmail.split('@').first;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: unread > 0 ? Colors.white : Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _openChat(otherEmail, displayName, conv['other_role'] ?? ''),
        leading: _buildAvatar(avatarUrl, displayName),
        title: Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                style: TextStyle(
                  fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F8A7B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          lastText.isEmpty ? 'Tap to start chatting' : lastText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: unread > 0 ? Colors.black87 : Colors.grey.shade600,
            fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: Text(
          _formatTime(lastTime),
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String avatarUrl, String displayName) {
    // Generate consistent color based on display name
    final colorIndex = displayName.isNotEmpty 
        ? displayName.codeUnits.fold(0, (a, b) => a + b) % _avatarColors.length
        : 0;
    final backgroundColor = _avatarColors[colorIndex];
    final textColor = _getContrastColor(backgroundColor);
    
    final initial = displayName.isNotEmpty 
        ? displayName[0].toUpperCase() 
        : '?';
    
    final fallbackAvatar = CircleAvatar(
      radius: 24,
      backgroundColor: backgroundColor,
      child: Text(
        initial,
        style: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // If no avatar URL, show fallback with random color
    if (avatarUrl.isEmpty) {
      return fallbackAvatar;
    }

    // Try to load network image with error handling
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: NetworkImage(avatarUrl),
      onBackgroundImageError: (exception, stackTrace) {
        // Image failed to load (CORS or other error)
        print('Avatar load error: $exception');
      },
      child: Container(), // Empty child, image will be background
    );
  }

  // Predefined vibrant colors for avatars
  static final List<Color> _avatarColors = [
    Color(0xFFE53935), // Red
    Color(0xFFD81B60), // Pink
    Color(0xFF8E24AA), // Purple
    Color(0xFF5E35B1), // Deep Purple
    Color(0xFF3949AB), // Indigo
    Color(0xFF1E88E5), // Blue
    Color(0xFF039BE5), // Light Blue
    Color(0xFF00ACC1), // Cyan
    Color(0xFF00897B), // Teal
    Color(0xFF43A047), // Green
    Color(0xFF7CB342), // Light Green
    Color(0xFFC0CA33), // Lime
    Color(0xFFFDD835), // Yellow
    Color(0xFFFFB300), // Amber
    Color(0xFFFB8C00), // Orange
    Color(0xFFF4511E), // Deep Orange
    Color(0xFF6D4C41), // Brown
    Color(0xFF757575), // Grey
    Color(0xFF546E7A), // Blue Grey
  ];

  // Get contrasting text color (white for dark backgrounds, dark for light backgrounds)
  Color _getContrastColor(Color background) {
    // Calculate luminance - if > 0.5, background is light, use dark text
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  String _formatTime(String isoTime) {
    if (isoTime.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoTime);
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      return '${dt.day}/${dt.month}';
    } catch (e) {
      return '';
    }
  }
}
