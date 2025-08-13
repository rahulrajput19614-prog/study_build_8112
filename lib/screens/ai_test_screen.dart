import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiTestScreen extends StatefulWidget {
  const AiTestScreen({super.key});

  @override
  State<AiTestScreen> createState() => _AiTestScreenState();
}

class _AiTestScreenState extends State<AiTestScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _loading = false;

  Future<void> _sendQuestion() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _loading = true;
      _response = '';
    });

    try {
      final uri = Uri.parse('https://study-build-8112-1.onrender.com/solve-doubt');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({'question': question});

      final res = await http.post(uri, headers: headers, body: body);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _response = data['answer'] ?? 'No answer');
      } else {
        setState(() => _response = 'Error: ${res.statusCode}');
      }
    } catch (e) {
      setState(() => _response = 'Network error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Your question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _sendQuestion,
              child: const Text('Ask AI'),
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (_response.isNotEmpty)
              Text(
                _response,
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
