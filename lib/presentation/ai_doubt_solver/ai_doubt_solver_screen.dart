import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _checkForUpdate(); // ✅ Trigger update check
  }

  Future<void> _checkForUpdate() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await remoteConfig.fetchAndActivate();

    final latestVersion = remoteConfig.getString('latest_app_version');
    final updateLink = remoteConfig.getString('update_link');

    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version;

    if (latestVersion != currentVersion) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('अपडेट उपलब्ध है'),
          content: Text('नया वर्शन $latestVersion उपलब्ध है। क्या आप अपडेट करना चाहेंगे?'),
          actions: [
            TextButton(
              onPressed: () => launchUrl(Uri.parse(updateLink)),
              child: const Text('अभी अपडेट करें'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('बाद में'),
            ),
          ],
        ),
      );
    }
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
                final content = msg['content'] ?? '';
                final isUser = role == 'user';
                final isError = role == 'error';

                final bubbleColor = isError
                    ? Colors.red.shade100
                    : isUser
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceVariant;

                final align =
                    isUser ? Alignment.centerRight : Alignment.centerLeft;

                return Align(
                  alignment: align,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(content),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    tooltip: _isListening ? 'Stop listening' : 'Start listening',
                    icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                    onPressed: _isListening ? _stopListening : _startListening,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendToAI(_controller.text),
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
            ),
          ),
        ],
      ),
    );
  }
}
