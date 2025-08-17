import 'package:flutter/material.dart';

class StudyReelsScreen extends StatelessWidget {
  const StudyReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Reels')),
      body: const Center(child: Text('Watch Study Reels here')),
    );
  }
}
