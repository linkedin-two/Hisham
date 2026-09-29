import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edzkool/utils/session_manager.dart';

const bool kUseDevDefaultEmail = false;
const String kDevDefaultEmail = 'bobbykboseoffice@gmail.com';

final userEmailProvider = StateProvider<String?>((ref) {
  if (kUseDevDefaultEmail) return kDevDefaultEmail;
  return null;
});

// Function to initialize email from SessionManager
Future<void> initializeUserEmail(WidgetRef ref) async {
  final storedEmail = await SessionManager.getUserEmail();
  if (storedEmail != null && storedEmail.isNotEmpty) {
    ref.read(userEmailProvider.notifier).state = storedEmail;
  }
}
