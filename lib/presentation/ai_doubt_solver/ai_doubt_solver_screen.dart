import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Doubt Solver',
      theme: _isDark ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(toggleTheme: () {
        setState(() {
          _isDark = !_isDark;
        });
      }),
      routes: {
        '/ai': (context) => AIDoubtScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  HomeScreen({required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Rahul'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: toggleTheme,
          ),
        ],
      ),
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
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> getAIAnswer(String question) async {
    setState(() {
      _loading = true;
      messages.add({"role": "user", "content": question});
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer YOUR_API_KEY', // ← अपना OpenAI API key डालो
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

  void startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
      });
    }
  }

  void stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> pickPDF() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      final fileName = result.files.single.name;
      setState(() {
        messages.add({"role": "user", "content": "PDF uploaded: $fileName"});
      });
    }
  }

  Widget buildMessageBubble(String role, String content) {
    bool isUser = role == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Doubt Solver'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: pickPDF,
          ),
        ],
      ),
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
                IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  onPressed: _isListening ? stopListening : startListening,
                ),
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
