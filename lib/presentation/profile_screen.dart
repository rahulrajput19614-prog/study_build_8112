import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Profile Picture
            const CircleAvatar(
              radius: 50,
              // Agar asset use karna hai to niche wala use karo
              // backgroundImage: AssetImage('assets/images/user.png'),

              // Test ke liye network image
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),

            const SizedBox(height: 10),

            // User Name
            const Text(
              'Rahul Sharma',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            // Email
            const Text(
              'rahul@example.com',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _StatItem(label: 'Tests', value: '12'),
                _StatItem(label: 'Doubts', value: '34'),
                _StatItem(label: 'Streak', value: '7 days'),
              ],
            ),

            const SizedBox(height: 30),

            // Options
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // TODO: Add navigation to settings screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // TODO: Add logout logic
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
