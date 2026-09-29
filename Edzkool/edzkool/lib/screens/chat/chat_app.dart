import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/chat_entry_screen.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatEntryScreen();
  }
}

// Extension to integrate with existing app
// Usage: Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatApp()));
