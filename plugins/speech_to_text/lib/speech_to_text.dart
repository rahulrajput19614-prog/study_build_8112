import 'dart:async';

class SpeechToText {
  bool _isListening = false;
  bool _isAvailable = true;

  /// Simulates plugin initialization
  Future<bool> initialize() async {
    print("SpeechToText plugin initialized");
    return _isAvailable;
  }

  /// Simulates speech recognition start
  void listen({required Function(dynamic result) onResult}) {
    _isListening = true;
    print("Listening started");

    // Simulate result after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      onResult("Simulated speech result");
    });
  }

  /// Simulates stopping speech recognition
  void stop() {
    _isListening = false;
    print("Listening stopped");
  }

  /// Getter for listening state
  bool get isListening => _isListening;

  /// Getter for availability
  bool get isAvailable => _isAvailable;
}
