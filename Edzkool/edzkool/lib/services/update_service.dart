import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import 'package:flutter/material.dart';

class UpdateService {
  static Future<bool> checkForUpdates(BuildContext context, String apiBaseUrl) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      int currentVersionCode = int.parse(packageInfo.buildNumber);

      final response = await http.get(Uri.parse('\/api/users/latest-app-version/'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
           final data = responseData['data'];
           int latestVersionCode = data['version_code'];

           if (latestVersionCode > currentVersionCode) {
             bool isMandatory = data['is_mandatory'] ?? false;
             _showUpdateDialog(
               context, 
               data['apk_url'], 
               data['release_notes'],
               isMandatory
             );
             return isMandatory; // true if we should block the app
           }
        }
      }
    } catch (e) {
      print("Failed to check for updates: \");
    }
    return false;
  }

  static void _showUpdateDialog(BuildContext context, String apkUrl, String releaseNotes, bool isMandatory) {
    showDialog(
      context: context,
      barrierDismissible: !isMandatory, 
      builder: (context) {
        bool isDownloading = false;
        double progress = 0.0;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async => !isMandatory,
              child: AlertDialog(
                title: const Text("New Update Available!"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(releaseNotes),
                    if (isDownloading) ...[
                      const SizedBox(height: 20),
                      const Text("Downloading..."),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progress / 100),
                      const SizedBox(height: 8),
                      Text("\%"),
                    ]
                  ],
                ),
                actions: [
                  if (!isMandatory && !isDownloading)
                    TextButton(
                      child: const Text("Later"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  if (!isDownloading)
                    ElevatedButton(
                      child: const Text("Update Now"),
                      onPressed: () {
                        setState(() {
                          isDownloading = true;
                        });
                        _downloadAndInstall(apkUrl, (val) {
                           setState(() { progress = val; });
                        });
                      },
                    )
                ],
              ),
            );
          }
        );
      }
    );
  }

  static void _downloadAndInstall(String apkUrl, Function(double) onProgress) {
    try {
      OtaUpdate().execute(
        apkUrl,
        destinationFilename: 'edzkool_update.apk',
      ).listen(
        (OtaEvent event) {
          if (event.status == OtaStatus.DOWNLOADING) {
             onProgress(double.tryParse(event.value ?? '0') ?? 0.0);
          } else if (event.status == OtaStatus.INSTALLING) {
             print('Installation starting...');
          }
        },
      );
    } catch (e) {
      print('Failed to make OTA update. Details: \');
    }
  }
}
