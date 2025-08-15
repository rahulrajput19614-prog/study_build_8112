import 'package:flutter/material.dart';
import '../../core/app_export.dart'; // If needed for theme or navigation

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Build Home'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.profileScreen);
              },
              child: const Text('Open Profile'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.aiDoubtScreen);
              },
              child: const Text('AI Doubt Solver'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.studyReelsScreen);
              },
              child: const Text('Study Reels'),
            ),
          ],
        ),
      ),
    );
  }
}
