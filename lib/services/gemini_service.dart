Future<String> generateStudyRecommendations({
  required double overallScore,
  required Map<String, double> subjectScores,
  required List<String> weakTopics,
  required int timeSpent,
  required double accuracyRate,
}) async {
  final subjectScoreText = subjectScores.entries
      .map((e) => '${e.key}: ${e.value.toStringAsFixed(1)}%')
      .join(', ');
  final weakTopicText = weakTopics.join(', ');

  final prompt = '''
As an AI tutor, analyze this student's test performance and provide personalized study recommendations:

Overall Score: ${overallScore.toStringAsFixed(1)}%
Subject Scores: $subjectScoreText
Weak Topics: $weakTopicText
Time Spent: $timeSpent minutes
Accuracy Rate: ${accuracyRate.toStringAsFixed(1)}%

Please provide:
1. 3-4 specific study recommendations
2. Priority areas to focus on
3. Suggested practice methods
4. Time management tips

Keep recommendations concise and actionable for exam preparation.
''';

  try {
    // Use GenerativeModel directly instead of undefined functions
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-002',
      apiKey: 'YOUR_API_KEY', // Add your API key here
    );
    
    final content = Content.text(prompt);
    final response = await model.generateContent([content]);
    
    return response.text ?? 'No recommendations generated';
  } catch (e) {
    return 'Unable to generate AI recommendations at this time. Please focus on your weak topics: $weakTopicText';
  }
}
