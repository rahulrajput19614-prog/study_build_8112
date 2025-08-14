import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateChecker {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      // Optional: Set default values
      await remoteConfig.setDefaults(<String, dynamic>{
        'latest_version': '1.0.0',
        'update_required': false,
        'update_message': 'A new version is available. Please update.',
      });

      // Fetch and activate
      await remoteConfig.fetchAndActivate();

      final latestVersion = remoteConfig.getString('latest_version');
      final updateRequired = remoteConfig.getBool('update_required');
      final updateMessage = remoteConfig.getString('update_message');

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (updateRequired && latestVersion != currentVersion) {
        _showUpdateDialog(context, updateMessage);
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  static void _showUpdateDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Update Available'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Replace with your app store link
              // launchUrl(Uri.parse('https://your-app-store-link.com'));
              Navigator.of(context).pop();
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }
}
