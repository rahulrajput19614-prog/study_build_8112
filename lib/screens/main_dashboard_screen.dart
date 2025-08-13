import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = 0;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  final categories = [
    {'title': 'SSC', 'color': Colors.blueAccent},
    {'title': 'Railway', 'color': Colors.green},
    {'title': 'UPSC', 'color': Colors.deepPurple},
    {'title': 'Banking', 'color': Colors.orange},
  ];

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      const HomeTab(),
      buildAiTab(),
      const ReelsTab(),
      const ProfileTab(),
    ]);
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget buildAiTab() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_loading && index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('AI is typing…'),
                  );
                }
                final msg = _messages[index];
                final role = msg['role'];
                final content = msg['content'];
                final isUser = role == 'user';
                final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
                final bubbleColor = isUser
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceVariant;

                return Align(
                  alignment: align,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(content ?? ''),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Apna sawal likhiye...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _sendToAI(_controller.text),
                child: const Text('Ask'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sendToAI(String prompt) async {
    if (prompt.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'content': prompt});
      _loading = true;
    });
    _controller.clear();

    try {
      final uri = Uri.parse('https://study-build-8112-1.onrender.com/solve-doubt');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({'question': prompt});

      final resp = await http.post(uri, headers: headers, body: body);
      final data = jsonDecode(resp.body);
      final reply = data['answer'] ?? 'No response';

      setState(() {
        _messages.add({'role': 'assistant', 'content': reply.trim()});
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': 'Network error: $e'});
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Exam'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 4.w,
                crossAxisSpacing: 4.w,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final item = categories[index];
                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item['title']} selected')),
                    );
                  },
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: item['color'] as Color,
                    child: Center(
                      child: Text(
                        item['title']!,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.video_collection), label: 'Reels'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('🏠 Home'));
}

class ReelsTab extends StatelessWidget {
  const ReelsTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('🎬 Reels'));
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('👤 Profile'));
}
