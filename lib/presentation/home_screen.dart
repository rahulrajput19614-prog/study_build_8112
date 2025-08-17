import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Build Home'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 Daily Test
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.assignment, color: Colors.blue),
                title: const Text("Daily Test"),
                subtitle: const Text("Attempt daily quizzes & PYQs"),
                onTap: () {
                  // Daily Test screen navigation
                  Navigator.pushNamed(context, '/daily-test');
                },
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 Current Affairs
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.newspaper, color: Colors.green),
                title: const Text("Current Affairs"),
                subtitle: const Text("Stay updated with daily news"),
                onTap: () {
                  Navigator.pushNamed(context, '/current-affairs');
                },
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 Book Revision
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.menu_book, color: Colors.orange),
                title: const Text("Book Revision"),
                subtitle: const Text("Revise important notes & books"),
                onTap: () {
                  Navigator.pushNamed(context, '/book-revision');
                },
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 AI Doubt Solver
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.psychology, color: Colors.purple),
                title: const Text("AI Doubt Solver"),
                subtitle: const Text("Ask questions & clear your doubts"),
                onTap: () {
                  Navigator.pushNamed(context, '/ai-doubt');
                },
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 Study Reels
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.video_library, color: Colors.red),
                title: const Text("Study Reels"),
                subtitle: const Text("Watch short study related videos"),
                onTap: () {
                  Navigator.pushNamed(context, '/reels');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
