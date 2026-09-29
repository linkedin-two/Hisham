import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user.dart';
import '../../models/message.dart';
import '../../utils/colors/colors.dart';
import '../../screens/notes/logo.dart';
import '../../utils/session_manager.dart';

// Image picker - platform specific
Future<XFile?> _pickImageHelper() async {
  final picker = ImagePicker();
  return await picker.pickImage(source: ImageSource.gallery);
}

// API Configuration - Using edzkool chat API
String get _baseUrl {
  return 'https://edzkool.publicvm.com/api';
}

String? _currentEmail;

Map<String, String> get _headers {
  final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
  if (_currentEmail != null) {
    headers['X-User-Email'] = _currentEmail!;
  }
  return headers;
}

Map<String, String> get _authHeaders {
  final headers = <String, String>{};
  if (_currentEmail != null) {
    headers['X-User-Email'] = _currentEmail!;
  }
  return headers;
}

class ChatScreen extends StatefulWidget {
  final User user;
  final String? currentUserEmail;

  const ChatScreen({super.key, required this.user, this.currentUserEmail});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;
  File? _selectedImage;

  // API Methods inlined
  Future<List<Message>> _getMessages(String otherEmail) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/messages?email=${Uri.encodeComponent(_currentEmail ?? '')}&other_email=${Uri.encodeComponent(otherEmail)}'
      );
      final response = await http.get(
        url,
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['messages'] != null) {
          final messages = (data['messages'] as List).map((m) {
            final isMe = m['sender'] == _currentEmail;
            return Message.fromJson(m, isMe);
          }).toList();
          return messages;
        }
      }
      return [];
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> _sendMessage(String toEmail, String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send'),
        headers: _headers,
        body: {
          'from_email': _currentEmail ?? '',
          'to_email': toEmail,
          'text': text,
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'status': false, 'error': 'Server error: ${response.statusCode}'};
    } catch (e) {
      return {'status': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _sendMessageWithImage(String toEmail, String text, File image) async {
    try {
      final uri = Uri.parse('$_baseUrl/send');
      final request = http.MultipartRequest('POST', uri);
      
      if (_currentEmail != null) {
        request.headers['X-User-Email'] = _currentEmail!;
      }
      
      request.fields['from_email'] = _currentEmail ?? '';
      request.fields['to_email'] = toEmail;
      if (text.isNotEmpty) {
        request.fields['text'] = text;
      }
      
      final stream = http.ByteStream(image.openRead());
      final length = await image.length();
      final multipartFile = http.MultipartFile('image', stream, length, filename: image.path.split('/').last);
      request.files.add(multipartFile);
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return jsonDecode(responseData);
      }
      return {'status': false, 'error': 'Server error: ${response.statusCode}'};
    } catch (e) {
      return {'status': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _editMessage(int messageId, String newText) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/messages/$messageId/edit'),
        headers: _headers,
        body: {'text': newText},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'status': false, 'error': 'Server error: ${response.statusCode}'};
    } catch (e) {
      return {'status': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _deleteMessage(int messageId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/messages/$messageId/delete'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'status': false, 'error': 'Server error: ${response.statusCode}'};
    } catch (e) {
      return {'status': false, 'error': e.toString()};
    }
  }

  @override
  void initState() {
    super.initState();
    // Set current email for API authentication
    if (widget.currentUserEmail != null) {
      _currentEmail = widget.currentUserEmail;
      _loadMessages();
      _startAutoRefresh();
    } else {
      SessionManager.getUserEmail().then((email) {
        if (mounted) {
          setState(() {
            _currentEmail = email;
          });
          _loadMessages();
          _startAutoRefresh();
        }
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) _loadMessages();
    });
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _getMessages(widget.user.email);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load messages: $e';
        });
      }
    }
  }

  void _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    _messageController.clear();
    
    try {
      Map<String, dynamic> result;
      if (_selectedImage != null) {
        result = await _sendMessageWithImage(widget.user.email, text, _selectedImage!);
        setState(() => _selectedImage = null);
      } else {
        result = await _sendMessage(widget.user.email, text);
      }
      
      if (result['status'] == true) {
        _loadMessages();
      } else {
        _showErrorSnackBar(result['error'] ?? 'Failed to send message');
      }
    } catch (e) {
      _showErrorSnackBar('Network error: $e');
    }
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      _showErrorSnackBar('Image upload not supported on web');
      return;
    }
    try {
      final picked = await _pickImageHelper();
      if (picked != null && picked.path != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadMessages,
        ),
      ),
    );
  }

  void _handleEditMessage(int messageId, String currentText) async {
    final controller = TextEditingController(text: currentText);
    final newText = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(controller: controller, maxLines: null),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (newText != null && newText.isNotEmpty) {
      final result = await _editMessage(messageId, newText);
      if (result['status'] == true) _loadMessages();
    }
  }

  void _handleDeleteMessage(int messageId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      final result = await _deleteMessage(messageId);
      if (result['status'] == true) _loadMessages();
    }
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
              child: Column(
                children: [
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.red.shade100,
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                          TextButton(
                            onPressed: _loadMessages,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadMessages,
                      child: _isLoading && _messages.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : _messages.isEmpty
                              ? ListView(
                                  children: const [
                                    Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 100),
                                        child: Text(
                                          "No messages yet\nPull to refresh",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.grey, fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: _messages.length,
                                  itemBuilder: (context, index) {
                                    final msg = _messages[index];
                                    return _ChatBubble(
                                      text: msg.text,
                                      isMe: msg.isMe,
                                      time: msg.time,
                                      delivered: msg.delivered,
                                      seen: msg.seen,
                                      onEdit: msg.isMe && msg.id != null ? () => _handleEditMessage(msg.id!, msg.text) : null,
                                      onDelete: msg.isMe && msg.id != null ? () => _handleDeleteMessage(msg.id!) : null,
                                    );
                                  },
                                ),
                    ),
                  ),
                  _MessageInput(
                    controller: _messageController,
                    onSend: _handleSend,
                    onAttachImage: _pickImage,
                    selectedImage: _selectedImage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ChatBubble Widget
class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String? time;
  final bool delivered;
  final bool seen;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ChatBubble({
    required this.text,
    required this.isMe,
    this.time,
    this.delivered = false,
    this.seen = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth * 0.75;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 50 : 10,
          right: isMe ? 10 : 50,
          top: 4,
          bottom: 4,
        ),
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        child: CustomPaint(
          painter: _BubblePainter(isMe: isMe),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        text,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 15,
                          height: 1.3,
                        ),
                        softWrap: true,
                      ),
                    ),
                    if (isMe && (onEdit != null || onDelete != null))
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          onSelected: (value) {
                            if (value == 'edit') onEdit?.call();
                            if (value == 'delete') onDelete?.call();
                          },
                          itemBuilder: (context) => [
                            if (onEdit != null)
                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            if (onDelete != null)
                              const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                          child: const Icon(Icons.more_vert, size: 16, color: Colors.white70),
                        ),
                      ),
                  ],
                ),
                if (time != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time!,
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          seen ? Icons.done_all : (delivered ? Icons.done : Icons.access_time),
                          size: 14,
                          color: seen ? Colors.blue.shade300 : Colors.white70,
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final bool isMe;

  _BubblePainter({required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isMe ? const Color(0xFF0F8A7B) : const Color(0xFFEFEFEF)
      ..style = PaintingStyle.fill;

    final path = Path();
    const radius = 18.0;
    const tailSize = 10.0;

    if (isMe) {
      path.moveTo(radius, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, size.height - radius - tailSize);
      path.quadraticBezierTo(
        size.width,
        size.height - tailSize,
        size.width - radius,
        size.height - tailSize,
      );
      path.lineTo(size.width - tailSize, size.height - tailSize);
      path.quadraticBezierTo(
        size.width + 2,
        size.height + 2,
        size.width - tailSize - 4,
        size.height,
      );
      path.lineTo(radius, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - radius);
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
    } else {
      path.moveTo(radius, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      );
      path.lineTo(tailSize + 4, size.height);
      path.quadraticBezierTo(
        -2,
        size.height + 2,
        tailSize,
        size.height - tailSize,
      );
      path.lineTo(radius, size.height - tailSize);
      path.quadraticBezierTo(0, size.height - tailSize, 0, size.height - radius - tailSize);
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// MessageInput Widget
class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttachImage;
  final File? selectedImage;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    this.onAttachImage,
    this.selectedImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: onAttachImage,
              icon: Icon(
                selectedImage != null ? Icons.image : Icons.camera_alt_outlined,
                color: selectedImage != null ? const Color(0xFF0F8A7B) : Colors.grey,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: selectedImage != null ? "Add a caption..." : "Type your message here",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    suffixIcon: selectedImage != null
                        ? GestureDetector(
                            onTap: onAttachImage,
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                image: DecorationImage(
                                  image: FileImage(selectedImage!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F8A7B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
