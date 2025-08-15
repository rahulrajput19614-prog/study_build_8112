import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

Future<void> checkForUpdate(BuildContext context) async {
  final remoteConfig = FirebaseRemoteConfig.instance;

  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    minimumFetchInterval: const Duration(hours: 1),
  ));

  await remoteConfig.fetchAndActivate();

  final latestVersion = remoteConfig.getString('latest_app_version');
  final updateLink = remoteConfig.getString('update_link');
  final changelog = remoteConfig.getString('update_changelog');

  final info = await PackageInfo.fromPlatform();
  final currentVersion = info.version;

  if (latestVersion != currentVersion) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('अपडेट उपलब्ध है'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('नया वर्शन $latestVersion उपलब्ध है।'),
            const SizedBox(height: 8),
            Text('🔄 बदलाव:\n$changelog'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => launchUrl(Uri.parse(updateLink)),
            child: const Text('अभी अपडेट करें'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('बाद में'),
          ),
        ],
      ),
    );
  }
}
