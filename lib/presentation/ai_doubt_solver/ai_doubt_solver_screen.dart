import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/gemini_client.dart';
import '../../services/gemini_service.dart';
import './widgets/chat_message_widget.dart';
import './widgets/typing_indicator_widget.dart';

class AiDoubtSolverScreen extends StatefulWidget {
  const AiDoubtSolverScreen({super.key});

  @override
  State<AiDoubtSolverScreen> createState() => _AiDoubtSolverScreenState();
}

class _AiDoubtSolverScreenState extends State<AiDoubtSolverScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late GeminiClient _geminiClient;

  @override
  void initState() {
    super.initState();
    try {
      final service = GeminiService();
      _geminiClient = GeminiClient(service.dio, service.authApiKey);
      _addWelcomeMessage();
    } catch (e) {
      _addErrorMessage(
          'AI service is not available. Please check your internet connection.');
    }
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          text:
              "नमस्ते! मैं आपका AI study assistant हूं। आप मुझसे किसी भी विषय से जुड़ा सवाल पूछ सकते हैं - Math, Science, History, या कोई भी competitive exam का doubt। मैं Hindi और English दोनों में जवाब दे सकता हूं। आपका सवाल क्या है?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _addErrorMessage(String error) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: error,
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ),
      );
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Create enhanced prompt for educational context
      final enhancedPrompt = _createEducationalPrompt(message);

      final response = await _geminiClient.createChat(
        messages: [Message(role: 'user', content: enhancedPrompt)],
        model: 'gemini-1.5-flash-002',
        maxTokens: 1024,
        temperature: 0.7,
      );

      setState(() {
        _messages.add(
          ChatMessage(
            text: response.text,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isTyping = false;
      });
    } on GeminiException catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                'Sorry, मैं अभी आपका सवाल का जवाब नहीं दे पा रहा। कृपया बाद में try करें। Error: ${e.message}',
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                'कुछ technical problem है। Please check your internet connection और फिर try करें।',
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  String _createEducationalPrompt(String userMessage) {
    return """
You are an expert educational AI assistant for competitive exam preparation in India. 
The student has asked: "$userMessage"

Please provide a comprehensive, educational response following these guidelines:
1. Answer in a mix of Hindi and English as appropriate for Indian students
2. If it's a subject question, provide step-by-step explanation
3. For competitive exam questions, mention which exams this topic appears in (UPSC, SSC, Banking, etc.)
4. Include relevant examples and practical applications
5. If it's a math/science problem, show the complete solution process
6. End with a motivational note for exam preparation
7. Keep the tone friendly but professional
8. If you don't know something, honestly say so and suggest alternative resources

Student's question: $userMessage
""";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _addWelcomeMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.psychology,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Doubt Solver',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Ask any study question',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _clearChat,
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation with AI',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ask any study-related question',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.7),
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return const TypingIndicatorWidget();
                      }
                      return ChatMessageWidget(message: _messages[index]);
                    },
                  ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask your doubt here...',
                        hintStyle: GoogleFonts.roboto(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.6),
                        ),
                        prefixIcon: Icon(
                          Icons.help_outline,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.6),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isTyping,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: _isTyping ? null : _sendMessage,
                    mini: true,
                    backgroundColor: _isTyping
                        ? Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.3)
                        : Theme.of(context).primaryColor,
                    child: _isTyping
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          )
                        : const Icon(Icons.send, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
