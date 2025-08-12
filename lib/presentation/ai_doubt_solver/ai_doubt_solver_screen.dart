import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Doubt Solver',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomeScreen(),
      routes: {
        '/ai': (context) => AIDoubtScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome Rahul')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/ai');
          },
          child: Text('Open AI Doubt Solver'),
        ),
      ),
    );
  }
}

class AIDoubtScreen extends StatefulWidget {
  @override
  _AIDoubtScreenState createState() => _AIDoubtScreenState();
}

class _AIDoubtScreenState extends State<AIDoubtScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool _loading = false;

  Future<void> getAIAnswer(String question) async {
    setState(() {
      _loading = true;
      messages.add({"role": "user", "content": question});
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer YOUR_API_KEY', // ← यहाँ अपना OpenAI API key डालना है
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": messages,
      }),
    );

    final data = jsonDecode(response.body);
    final aiReply = data['choices'][0]['message']['content'];

    setState(() {
      messages.add({"role": "assistant", "content": aiReply});
      _loading = false;
    });
  }

  Widget buildMessageBubble(String role, String content) {
    bool isUser = role == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Doubt Solver')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return buildMessageBubble(msg['role']!, msg['content']!);
              },
            ),
          ),
          if (_loading) CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Apna sawal likhiye...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      getAIAnswer(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                  child: Text('Ask'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
