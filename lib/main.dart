import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ Add this

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import '../presentation/bottom_nav.dart';
import '../presentation/ai_doubt_solver/ai_doubt_solver_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase initialization
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
              child: child!,
            );
          },
        );
      },
    );
  }
}
