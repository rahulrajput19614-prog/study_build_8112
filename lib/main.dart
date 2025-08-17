import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'widgets/custom_error_widget.dart';
import 'presentation/bottom_nav.dart';

// ✅ Import all screens
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
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setDefaults({'latest_version': '1.0.0'});
      await remoteConfig.fetchAndActivate();

      final latestVersion = remoteConfig.getString('latest_version');
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (currentVersion != latestVersion && context.mounted) {
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
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const BottomNav(),
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
              data: mediaQuery.copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}

/// ----------------------------
/// ✅ SplashScreen
/// ----------------------------
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
      Navigator.pushReplacementNamed(context, '/login');
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

/// ----------------------------
/// ✅ LoginScreen
/// ----------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSigningIn = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      debugPrint("⚠️ Google Sign-In Failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Failed: $e")),
        );
      }
    } finally {
      setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.indigo],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 100, color: Colors.white),
            SizedBox(height: 5.h),
            const Text(
              "Study Build",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),

            // 🔹 Google Sign-In Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: Size(double.infinity, 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSigningIn ? null : _handleGoogleSignIn,
              icon: const Icon(Icons.login),
              label: _isSigningIn
                  ? const CircularProgressIndicator()
                  : const Text("Continue with Google"),
            ),
            SizedBox(height: 2.h),

            // 🔹 Mobile Login Placeholder
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                minimumSize: Size(double.infinity, 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // TODO: Add mobile login (OTP Firebase Auth)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mobile login coming soon 🚀")),
                );
              },
              child: const Text("Continue with Mobile"),
            ),
          ],
        ),
      ),
    );
  }
}
