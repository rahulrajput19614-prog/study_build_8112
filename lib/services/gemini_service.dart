import 'package:dio/dio.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final Dio _dio;
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal() {
    _initializeService();
  }

  void _initializeService() {
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY must be provided via --dart-define');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://generativelanguage.googleapis.com/v1',
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Dio get dio => _dio;
  String get authApiKey => apiKey;
}

class GeminiClient {
  final Dio dio;
  final String apiKey;

  GeminiClient(this.dio, this.apiKey);

  Future<Completion> createChat({
    required List<Message> messages,
    String model = 'gemini-1.5-flash-002',
    int maxTokens = 1024,
    double temperature = 1.0,
  }) async {
    try {
      final contents = messages
          .map((m) => {
                'role': m.role,
                'parts': m.content is String
                    ? [
                        {'text': m.content}
                      ]
                    : m.content,
              })
          .toList();

      final response = await dio.post(
        '/models/$model:generateContent',
        queryParameters: {
          'key': apiKey,
        },
        data: {
          'contents': contents,
          'generationConfig': {
            'maxOutputTokens': maxTokens,
            'temperature': temperature,
          },
        },
      );

      if (response.data['candidates'] != null &&
          response.data['candidates'].isNotEmpty &&
          response.data['candidates'][0]['content'] != null) {
        final parts = response.data['candidates'][0]['content']['parts'];
        final text = parts.isNotEmpty ? parts[0]['text'] : '';
        return Completion(text: text);
      } else {
        throw GeminiException(
          statusCode: response.statusCode ?? 500,
          message: 'Failed to parse response or empty response',
        );
      }
    } on DioException catch (e) {
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ?? e.message,
      );
    }
  }

  Future<String> generateStudyRecommendations({
    required double overallScore,
    required Map<String, double> subjectScores,
    required List<String> weakTopics,
    required int timeSpent,
    required double accuracyRate,
  }) async {
    final prompt = '''
As an AI tutor, analyze this student's test performance and provide personalized study recommendations:

Overall Score: ${overallScore.toStringAsFixed(1)}%
Subject Scores: ${subjectScores.entries.map((e) => '${e.key}: ${e.value.toStringAsFixed(1)}%').join(', ')}
Weak Topics: ${weakTopics.join(', ')}
Time Spent: ${timeSpent} minutes
Accuracy Rate: ${accuracyRate.toStringAsFixed(1)}%

Please provide:
1. 3-4 specific study recommendations
2. Priority areas to focus on
3. Suggested practice methods
4. Time management tips

Keep recommendations concise and actionable for exam preparation.
''';

    try {
      final message = Message(role: 'user', content: prompt);
      final response = await createChat(
        messages: [message],
        model: 'gemini-1.5-flash-002',
        maxTokens: 500,
        temperature: 0.7,
      );
      return response.text;
    } catch (e) {
      return 'Unable to generate AI recommendations at this time. Please focus on your weak topics: ${weakTopics.join(', ')}';
    }
  }

  Future<String> generatePerformanceInsights({
    required double currentScore,
    required double previousScore,
    required String performanceGrade,
    required int percentileRank,
  }) async {
    final prompt = '''
Analyze this student's academic performance and provide encouraging insights:

Current Score: ${currentScore.toStringAsFixed(1)}%
Previous Score: ${previousScore.toStringAsFixed(1)}%
Performance Grade: $performanceGrade
Percentile Rank: ${percentileRank}th percentile

Provide:
1. Performance trend analysis
2. Motivational message
3. Areas of improvement
4. Next steps for better performance

Keep the tone positive and educational.
''';

    try {
      final message = Message(role: 'user', content: prompt);
      final response = await createChat(
        messages: [message],
        model: 'gemini-1.5-flash-002',
        maxTokens: 300,
        temperature: 0.6,
      );
      return response.text;
    } catch (e) {
      final improvement =
          currentScore > previousScore ? 'improved' : 'needs focus';
      return 'Your performance has $improvement since last time. Keep practicing to reach your goals!';
    }
  }
}

class Message {
  final String role;
  final dynamic content;

  Message({required this.role, required this.content});
}

class Completion {
  final String text;

  Completion({required this.text});
}

class GeminiException implements Exception {
  final int statusCode;
  final String message;

  GeminiException({required this.statusCode, required this.message});

  @override
  String toString() => 'GeminiException: $statusCode - $message';
}
