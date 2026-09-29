import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edzkool/utils/session_manager.dart';
import '../providers/chat_provider.dart';
import 'conversations_screen.dart';

class ChatEntryScreen extends ConsumerStatefulWidget {
  const ChatEntryScreen({super.key});

  @override
  ConsumerState<ChatEntryScreen> createState() => _ChatEntryScreenState();
}

class _ChatEntryScreenState extends ConsumerState<ChatEntryScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    await initializeChatAuth(ref);
    final savedEmail = ref.read(currentUserEmailProvider);
    if (savedEmail.isNotEmpty) {
      _emailController.text = savedEmail;
      _enterChat(savedEmail);
    }
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_user_email', email);
  }

  Future<void> _enterChat(String email) async {
    if (email.trim().isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showError('Please enter a valid email');
      return;
    }

    setState(() => _isLoading = true);

    final token = await SessionManager.getStoredToken();
    if (token == null || token.isEmpty) {
      setState(() => _isLoading = false);
      _showError('Please sign in to the app before using chat');
      return;
    }

    await _saveEmail(email.trim());
    ref.read(authTokenProvider.notifier).state = token;
    ref.read(currentUserEmailProvider.notifier).state = email.trim();

    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ConversationsScreen(),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF144787), Color(0xFF006666)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.chat_bubble,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                const Text(
                  'EdVoyage Chat',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF144787),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect with medical professionals',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),
                
                // Email input
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey[500],
                    ),
                    prefixIcon: const Icon(Icons.email, color: Color(0xFF144787)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF144787), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Enter button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _enterChat(_emailController.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF144787),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Enter Chat',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Info text
                Text(
                  'Your email will be used to identify you in the chat system.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
