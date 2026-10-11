import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edzkool/utils/colors/colors.dart';

enum _UpdateStatus { idle, downloading, installing, error }

class UpdateService {
  /// Checks the server for updates.
  /// Returns `true` if a mandatory update is active (blocking standard app navigation),
  /// or `false` if the app can proceed to home/login screen.
  static Future<bool> checkForUpdates(BuildContext context, String apiBaseUrl) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      int currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 1;
      String currentVersionName = packageInfo.version;

      final url = Uri.parse('$apiBaseUrl/api/v1/users/latest-app-version/');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          int latestVersionCode = data['version_code'] is int
              ? data['version_code']
              : int.tryParse(data['version_code'].toString()) ?? 0;
          String latestVersionName = (data['version_name'] ?? '').toString();
          String apkUrl = (data['apk_url'] ?? '').toString().trim();
          String releaseNotes = (data['release_notes'] ?? '').toString().trim();
          bool isMandatory = data['is_mandatory'] == true;

          debugPrint('OTA Version Check -> Installed: v$currentVersionCode ($currentVersionName) | Server: v$latestVersionCode ($latestVersionName)');

          if (latestVersionCode > currentVersionCode && apkUrl.isNotEmpty) {
            if (!context.mounted) return false;

            // Display and AWAIT the dialog so the splash screen doesn't navigate away mid-download
            await showDialog<bool>(
              context: context,
              barrierDismissible: !isMandatory,
              builder: (dialogContext) => UpdateDialog(
                currentVersionCode: currentVersionCode,
                currentVersionName: currentVersionName,
                latestVersionCode: latestVersionCode,
                latestVersionName: latestVersionName,
                apkUrl: apkUrl,
                releaseNotes: releaseNotes,
                isMandatory: isMandatory,
              ),
            );

            // If mandatory, stay on splash screen (don't navigate into app)
            return isMandatory;
          }
        }
      }
    } catch (e) {
      debugPrint("UpdateService: Failed to check for updates -> $e");
    }
    return false;
  }
}

class UpdateDialog extends StatefulWidget {
  final int currentVersionCode;
  final String currentVersionName;
  final int latestVersionCode;
  final String latestVersionName;
  final String apkUrl;
  final String releaseNotes;
  final bool isMandatory;

  const UpdateDialog({
    super.key,
    required this.currentVersionCode,
    required this.currentVersionName,
    required this.latestVersionCode,
    required this.latestVersionName,
    required this.apkUrl,
    required this.releaseNotes,
    required this.isMandatory,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  _UpdateStatus _status = _UpdateStatus.idle;
  double _progress = 0.0;
  String _errorMessage = '';
  StreamSubscription<OtaEvent>? _otaSubscription;

  @override
  void dispose() {
    _otaSubscription?.cancel();
    super.dispose();
  }

  Future<void> _openBrowserDownload() async {
    try {
      final uri = Uri.parse(widget.apkUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint("UpdateDialog: Failed to launch browser URL -> $e");
    }
  }

  Future<void> _startOtaDownload() async {
    setState(() {
      _status = _UpdateStatus.downloading;
      _progress = 0.0;
      _errorMessage = '';
    });

    try {
      // 1. Request unknown package install permission on Android 8+
      if (await Permission.requestInstallPackages.isDenied) {
        final permStatus = await Permission.requestInstallPackages.request();
        if (permStatus.isDenied) {
          setState(() {
            _status = _UpdateStatus.error;
            _errorMessage =
                'Permission to install unknown apps was denied. Please allow it or download via your browser.';
          });
          return;
        }
      }

      // 2. Start OTA download with version-isolated filename
      _otaSubscription?.cancel();
      _otaSubscription = OtaUpdate()
          .execute(
        widget.apkUrl,
        destinationFilename: 'edzkool_v${widget.latestVersionCode}.apk',
      )
          .listen(
        (OtaEvent event) {
          if (!mounted) return;
          switch (event.status) {
            case OtaStatus.DOWNLOADING:
              setState(() {
                _status = _UpdateStatus.downloading;
                _progress = double.tryParse(event.value ?? '0') ?? _progress;
              });
              break;
            case OtaStatus.INSTALLING:
              setState(() {
                _status = _UpdateStatus.installing;
              });
              break;
            case OtaStatus.INSTALLATION_DONE:
              if (!widget.isMandatory && mounted) {
                Navigator.of(context).pop(true);
              }
              break;
            case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
              setState(() {
                _status = _UpdateStatus.error;
                _errorMessage =
                    'Installation permission denied. Please allow unknown sources in Android settings or download via browser.';
              });
              break;
            case OtaStatus.DOWNLOAD_ERROR:
              setState(() {
                _status = _UpdateStatus.error;
                _errorMessage =
                    'Download failed or was interrupted. Check your internet connection or use browser download.';
              });
              break;
            case OtaStatus.CHECKSUM_ERROR:
              setState(() {
                _status = _UpdateStatus.error;
                _errorMessage =
                    'APK file verification failed. The file may be corrupt. Please download directly in browser.';
              });
              break;
            case OtaStatus.INTERNAL_ERROR:
              setState(() {
                _status = _UpdateStatus.error;
                _errorMessage =
                    'Internal error during installation: ${event.value ?? "Unknown"}. Use browser download.';
              });
              break;
            case OtaStatus.ALREADY_RUNNING_ERROR:
              setState(() {
                _status = _UpdateStatus.error;
                _errorMessage =
                    'Another download is already running. Please wait a moment or restart the app.';
              });
              break;
            case OtaStatus.CANCELED:
              setState(() {
                _status = _UpdateStatus.idle;
              });
              break;
            default:
              break;
          }
        },
        onError: (err) {
          if (!mounted) return;
          setState(() {
            _status = _UpdateStatus.error;
            _errorMessage = 'Download error: $err. Please use browser download.';
          });
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _UpdateStatus.error;
        _errorMessage = 'Failed to start download: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canDismiss = !widget.isMandatory &&
        _status != _UpdateStatus.downloading &&
        _status != _UpdateStatus.installing;

    return PopScope(
      canPop: canDismiss,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Icon + Header
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    size: 32,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.isMandatory ? 'Mandatory Update Required' : 'New Update Available',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Version Badges Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Installed',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'v${widget.currentVersionCode} (${widget.currentVersionName})',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.grey.shade500),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Latest',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'v${widget.latestVersionCode}${widget.latestVersionName.isNotEmpty ? ' (${widget.latestVersionName})' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Release Notes
              if (widget.releaseNotes.isNotEmpty) ...[
                const Text(
                  'What\'s New:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.releaseNotes,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade800, height: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Dynamic Status / Progress Section
              if (_status == _UpdateStatus.downloading) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress > 0 ? (_progress / 100).clamp(0.0, 1.0) : null,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Downloading update...',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    Text(
                      '${_progress.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Please keep the app open to finish the download.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _openBrowserDownload,
                  icon: const Icon(Icons.open_in_browser, size: 16),
                  label: const Text('Download via Browser instead', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                ),
              ] else if (_status == _UpdateStatus.installing) ...[
                Column(
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Opening Package Installer...',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please tap "Install" on the screen prompt.',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ] else if (_status == _UpdateStatus.error) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, size: 18, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(fontSize: 11, color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _startOtaDownload,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _openBrowserDownload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        child: const Text('Browser', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                if (!widget.isMandatory) ...[
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
                  ),
                ],
              ] else ...[
                // Idle action buttons
                ElevatedButton.icon(
                  onPressed: _startOtaDownload,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Update Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _openBrowserDownload,
                  icon: const Icon(Icons.open_in_browser, size: 18),
                  label: const Text('Download via Browser', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade800,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                if (!widget.isMandatory) ...[
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Later', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
