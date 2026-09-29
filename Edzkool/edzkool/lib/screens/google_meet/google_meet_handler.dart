import 'package:flutter/material.dart';
import 'package:edzkool/screens/google_meet/models/google_meet_status.dart';
import 'package:edzkool/screens/google_meet/services/google_meet_api_service.dart';
import 'package:edzkool/screens/google_meet/widgets/google_meet_class_dialog.dart';
import 'package:edzkool/utils/session_manager.dart';
import 'package:url_launcher/url_launcher.dart';

final _googleMeetApiService = GoogleMeetApiService();

void _showSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

Future<void> _openMeetUrl(BuildContext context, GoogleMeetStatus status) async {
  final meetUrl = status.meetUrl;
  final schoolClass = status.schoolClass;

  if (meetUrl == null || meetUrl.isEmpty) {
    _showSnackBar(
      context,
      schoolClass != null
          ? 'Meet link not configured for Class $schoolClass'
          : 'Meet link not configured',
    );
    return;
  }

  final uri = Uri.tryParse(meetUrl);
  if (uri == null) {
    _showSnackBar(context, 'Invalid Meet link');
    return;
  }

  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      _showSnackBar(context, 'Could not open Meet link');
    }
  } catch (_) {
    if (context.mounted) {
      _showSnackBar(context, 'Could not open Meet link');
    }
  }
}

Future<void> handleGoogleMeetNavTap(BuildContext context) async {
  final token = await SessionManager.getStoredToken();
  if (token == null || token.isEmpty) {
    _showSnackBar(context, 'Please sign in to join Google Meet');
    return;
  }

  try {
    final statusResponse = await _googleMeetApiService.getStatus();
    if (!context.mounted) return;
    if (!statusResponse.isSuccess || statusResponse.data == null) {
      _showSnackBar(
        context,
        statusResponse.message.isNotEmpty
            ? statusResponse.message
            : 'Failed to load Google Meet status',
      );
      return;
    }

    var status = statusResponse.data!;

    if (!status.hasClass) {
      final selectedClass = await showGoogleMeetClassDialog(context);
      if (selectedClass == null || !context.mounted) return;

      try {
        final registerResponse = await _googleMeetApiService.registerClass(
          schoolClass: selectedClass,
        );

        if (registerResponse.isSuccess && registerResponse.data != null) {
          status = registerResponse.data!;
        } else {
          if (!context.mounted) return;
          _showSnackBar(
            context,
            registerResponse.message.isNotEmpty
                ? registerResponse.message
                : 'Failed to register class',
          );
          return;
        }
      } catch (e) {
        final message = e.toString();
        if (message.contains('class_already_set')) {
          final retryStatus = await _googleMeetApiService.getStatus();
          if (!context.mounted) return;
          if (retryStatus.data != null) {
            status = retryStatus.data!;
          }
        } else {
          if (!context.mounted) return;
          _showSnackBar(context, 'Failed to register class');
          return;
        }
      }
    }

    if (!context.mounted) return;
    await _openMeetUrl(context, status);
  } catch (e) {
    if (context.mounted) {
      _showSnackBar(context, 'Something went wrong. Please try again.');
    }
  }
}
