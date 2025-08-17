import 'package:flutter/material.dart';

class DailyTestScreen extends StatelessWidget {
  const DailyTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Test')),
      body: const Center(child: Text('Take your Daily Test here')),
    );
  }
}
