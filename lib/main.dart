
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/app_export.dart';
import 'widgets/custom_error_widget.dart';
import 'presentation/bottom_nav.dart';
import 'presentation/ai_doubt_solver/ai_doubt_solver_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  ErrorWidget.builder = (FlutterErrorDetails details) =>
      CustomErrorWidget(errorDetails: details);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> checkForUpdate(BuildContext context) async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setDefaults({'latest_version': '1.0.0'});
    await remoteConfig.fetchAndActivate();

    final latestVersion = remoteConfig.getString('latest_version');
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    if (currentVersion != latestVersion) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Update Available'),
          content: const Text('A new version of Study Build is available.'),
          actions: [
            TextButton(
              onPressed: () async {
                final url = Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.your.package',
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Builder(
          builder: (context) {
            // ✅ Trigger update check after build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              checkForUpdate(context);
            });

            return MaterialApp(
              title: 'Study Build',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.light,
              debugShowCheckedModeBanner: false,
              initialRoute: '/home',
              routes: {
                '/home': (context) => const BottomNav(),
                '/ai': (context) => AiDoubtSolverScreen(),
              },
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                return MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: TextScaler.linear(1.0),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        );
      },
    );
  }
}
