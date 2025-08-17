import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'ai_doubt_solver/ai_doubt_solver_screen.dart';
import 'study_reels/study_reels_screen.dart';
import 'daily_test/daily_test_screen.dart';
import 'book_revision/book_revision_screen.dart';
import 'current_affairs/current_affairs_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ProfileScreen(),
    AiDoubtSolverScreen(),
    StudyReelsScreen(),
    DailyTestScreen(),
    BookRevisionScreen(),
    CurrentAffairsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI Doubt'),
    BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Reels'),
    BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Test'),
    BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Revision'),
    BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Affairs'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
