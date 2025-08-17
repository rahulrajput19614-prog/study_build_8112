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

// 👇 Import all screens here
import 'presentation/home/home_screen.dart';
import 'presentation/profile/profile_screen.dart';
import 'presentation/ai_doubt_solver/ai_doubt_solver_screen.dart';
import 'presentation/study_reels/study_reels_screen.dart';
import 'presentation/daily_test/daily_test_screen.dart';
import 'presentation/book_revision/book_revision_screen.dart';
import 'presentation/current_affairs/current_affairs_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("⚠️ Firebase Init Failed: $e");
  }

  // Global error widget
  ErrorWidget.builder = (FlutterErrorDetails details) =>
      CustomErrorWidget(errorDetails: details);

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// ✅ Firebase Remote Config Update Check
  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setDefaults({'latest_version': '1.0.0'});
      await remoteConfig.fetchAndActivate();

      final latestVersion = remoteConfig.getString('latest_version');
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (currentVersion != latestVersion) {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text('Update Available'),
              content:
                  const Text('A new version of Study Build is available.'),
              actions: [
                TextButton(
                  onPressed: () async {
                    final url = Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.your.package');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Text('Update Now'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("⚠️ Update Check Failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Study Build',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
          routes: {
            // ✅ Bottom Nav / Main Home
            '/home': (context) => const BottomNav(),

            // ✅ Direct Pages
            '/main-home': (context) => const HomeScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/ai-doubt': (context) => const AiDoubtSolverScreen(),
            '/reels': (context) => const StudyReelsScreen(),
            '/daily-test': (context) => const DailyTestScreen(),
            '/book-revision': (context) => const BookRevisionScreen(),
            '/current-affairs': (context) => const CurrentAffairsScreen(),
          },
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(textScaleFactor: 1.0),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}

/// ✅ Simple Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      ),
    );
  }
}
