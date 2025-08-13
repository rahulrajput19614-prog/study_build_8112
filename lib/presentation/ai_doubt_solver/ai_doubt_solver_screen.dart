import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AiDoubtSolverScreen extends StatefulWidget {
  const AiDoubtSolverScreen({super.key});

  @override
  State<AiDoubtSolverScreen> createState() => _AiDoubtSolverScreenState();
}

class _AiDoubtSolverScreenState extends State<AiDoubtSolverScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = <Map<String, String>>[];
  bool _loading = false;

  late final stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _addSystemMessage('Hi 👋 I’m your AI doubt solver. Ask me anything!');
  }

  void _addSystemMessage(String content, {bool isError = false}) {
    setState(() {
      _messages.add({
        'role': isError ? 'error' : 'assistant',
        'content': content,
      });
    });
    _scrollToBottomSoon();
  }

  void _addUserMessage(String content) {
    setState(() {
      _messages.add({'role': 'user', 'content': content});
    });
    _scrollToBottomSoon();
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendToAI(String prompt) async {
    if (prompt.trim().isEmpty) return;

    _addUserMessage(prompt);
    setState(() => _loading = true);
    _controller.clear();

    try {
      final uri = Uri.parse('https://study-build-8112-1.onrender.com/solve-doubt');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({'question': prompt});

      final resp = await http.post(uri, headers: headers, body: body);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body);
        final reply = data['answer'] ?? 'No response';
        setState(() => _loading = false);
        _addSystemMessage(reply.trim());
      } else {
        setState(() => _loading = false);
        String msg = 'AI error: ${resp.statusCode}';
        try {
          final err = jsonDecode(resp.body);
          if (err is Map && err['error'] is String) {
            msg = 'AI error: ${err['error']}';
          }
        } catch (_) {}
        _addSystemMessage(msg, isError: true);
      }
    } catch (e) {
      setState(() => _loading = false);
      _addSystemMessage('Network error: $e', isError: true);
    }
  }

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (result != null) {
        final fileName = result.files.single.name;
        _addUserMessage('📄 PDF uploaded: $fileName');
      }
    } catch (e) {
      _addSystemMessage('PDF pick failed: $e', isError: true);
    }
  }

  Future<void> _startListening() async {
    try {
      final available = await _speech.initialize();
      if (!available) {
        _addSystemMessage('Mic not available or permission denied.', isError: true);
        return;
      }
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
      });
    } catch (e) {
      _addSystemMessage('Speech error: $e', isError: true);
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    if (_isListening) _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Doubt Solver'),
        actions: [
          IconButton(
            tooltip: 'Pick PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _pickPDF,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_loading && index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('AI is typing…'),
                    ),
                  );
                }
                final msg = _messages[index];
                final role = msg['role'] ?? 'assistant';
                final content =
