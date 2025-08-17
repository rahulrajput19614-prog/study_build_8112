import 'package:flutter/material.dart';

class CurrentAffairsScreen extends StatelessWidget {
  const CurrentAffairsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Current Affairs')),
      body: const Center(child: Text('Stay updated with Current Affairs')),
    );
  }
}
