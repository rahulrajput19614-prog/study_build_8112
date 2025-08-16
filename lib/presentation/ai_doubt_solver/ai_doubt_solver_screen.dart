import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'widgets/chat_message_widget.dart';
import 'models/chat_message.dart';  // ✅ add this import

class AiDoubtSolverScreen extends StatefulWidget {
  const AiDoubtSolverScreen({super.key});

  @override
  State<AiDoubtSolverScreen> createState() => _AiDoubtSolverScreenState();
}

class _AiDoubtSolverScreenState extends State<AiDoubtSolverScreen> {
  File? _selectedFile;
  late final stt.SpeechToText _speech;
  final TextEditingController _questionController = TextEditingController();
  late final FirebaseRemoteConfig _remoteConfig;
  final List<ChatMessage> _messages = []; // ✅ ab error nahi aayega

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _remoteConfig = FirebaseRemoteConfig.instance;
    _setupRemoteConfig();
  }

  Future<void> _setupRemoteConfig() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint("Remote Config setup error: $e");
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      debugPrint("File picking error: $e");
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(onResult: (result) {
        setState(() {
          _questionController.text = result.recognizedWords;
        });
      });
    }
  }

  void _stopListening() {
    _speech.stop();
  }

  void _submitQuestion() {
    if (_questionController.text.trim().isEmpty && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a question or upload a PDF")),
      );
      return;
    }

    setState(() {
      _messages.add(ChatMessage(
        message: _questionController.text,
        isUser: true,
      ));
    });

    _questionController.clear();

    // Example AI response (replace with actual API call)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(ChatMessage(
          message: "This is an AI-generated answer for your question.",
          isUser: false,
        ));
      });
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Doubt Solver"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedFile != null)
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(_selectedFile!.path.split('/').last),
              ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ChatMessageWidget(
                    message: _messages[index].message,
                    isUser: _messages[index].isUser,
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                hintText: "Type your question here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: _startListening,
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop),
                      onPressed: _stopListening,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload PDF"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submitQuestion,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
