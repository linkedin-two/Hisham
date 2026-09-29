import 'package:edzkool/_env/env.dart';
import 'package:edzkool/utils/app_log.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:safe_device/safe_device.dart';

/// Device integrity checks — blocks compromised devices in production.
class DeviceSecurity {
  DeviceSecurity._();

  static Future<DeviceSecurityResult> check() async {
    if (BaseUrl.isDebug || kIsWeb) {
      return const DeviceSecurityResult(safe: true);
    }

    try {
      final jailbroken = await SafeDevice.isJailBroken;
      final realDevice = await SafeDevice.isRealDevice;
      final devMode = await SafeDevice.isDevelopmentModeEnable;

      if (jailbroken) {
        AppLog.warn('Device security: jailbreak/root detected');
        return const DeviceSecurityResult(
          safe: false,
          reason: 'This app cannot run on rooted or jailbroken devices.',
        );
      }

      // Note: Emulator and Developer Mode checks are disabled for release
      // to avoid Google Play Pre-Launch Report automated test failures
      // and reviewer rejection under the "App Completeness" policy.

      return const DeviceSecurityResult(safe: true);
    } catch (e) {
      AppLog.error('Device security check failed', e);
      return const DeviceSecurityResult(safe: true);
    }
  }
}

class DeviceSecurityResult {
  final bool safe;
  final String? reason;

  const DeviceSecurityResult({required this.safe, this.reason});
}
