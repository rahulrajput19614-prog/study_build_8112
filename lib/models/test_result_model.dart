class TestResultModel {
  final String testId;
  final String testName;
  final double overallScore;
  final int percentileRank;
  final String performanceGrade;
  final int timeSpent;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int unattempted;
  final double accuracyRate;
  final DateTime completedAt;
  final Map<String, SubjectResult> subjectResults;
  final List<QuestionResult> questionResults;
  final TestStats? previousAttempt;

  TestResultModel({
    required this.testId,
    required this.testName,
    required this.overallScore,
    required this.percentileRank,
    required this.performanceGrade,
    required this.timeSpent,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.unattempted,
    required this.accuracyRate,
    required this.completedAt,
    required this.subjectResults,
    required this.questionResults,
    this.previousAttempt,
  });

  factory TestResultModel.fromJson(Map<String, dynamic> json) {
    return TestResultModel(
      testId: json['testId'] ?? '',
      testName: json['testName'] ?? '',
      overallScore: (json['overallScore'] ?? 0).toDouble(),
      percentileRank: json['percentileRank'] ?? 0,
      performanceGrade: json['performanceGrade'] ?? '',
      timeSpent: json['timeSpent'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      incorrectAnswers: json['incorrectAnswers'] ?? 0,
      unattempted: json['unattempted'] ?? 0,
      accuracyRate: (json['accuracyRate'] ?? 0).toDouble(),
      completedAt: DateTime.parse(
          json['completedAt'] ?? DateTime.now().toIso8601String()),
      subjectResults: Map<String, SubjectResult>.from(
        (json['subjectResults'] ?? {}).map(
          (key, value) => MapEntry(key, SubjectResult.fromJson(value)),
        ),
      ),
      questionResults: (json['questionResults'] as List? ?? [])
          .map((e) => QuestionResult.fromJson(e))
          .toList(),
      previousAttempt: json['previousAttempt'] != null
          ? TestStats.fromJson(json['previousAttempt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'testName': testName,
      'overallScore': overallScore,
      'percentileRank': percentileRank,
      'performanceGrade': performanceGrade,
      'timeSpent': timeSpent,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'unattempted': unattempted,
      'accuracyRate': accuracyRate,
      'completedAt': completedAt.toIso8601String(),
      'subjectResults':
          subjectResults.map((key, value) => MapEntry(key, value.toJson())),
      'questionResults': questionResults.map((e) => e.toJson()).toList(),
      'previousAttempt': previousAttempt?.toJson(),
    };
  }

  List<String> get weakTopics {
    return subjectResults.entries
        .where((entry) => entry.value.score < 60.0)
        .map((entry) => entry.key)
        .toList();
  }

  List<String> get strongTopics {
    return subjectResults.entries
        .where((entry) => entry.value.score >= 80.0)
        .map((entry) => entry.key)
        .toList();
  }
}

class SubjectResult {
  final String subject;
  final double score;
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpent;
  final String difficulty;

  SubjectResult({
    required this.subject,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeSpent,
    required this.difficulty,
  });

  factory SubjectResult.fromJson(Map<String, dynamic> json) {
    return SubjectResult(
      subject: json['subject'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      totalQuestions: json['totalQuestions'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      timeSpent: json['timeSpent'] ?? 0,
      difficulty: json['difficulty'] ?? 'Medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'timeSpent': timeSpent,
      'difficulty': difficulty,
    };
  }

  double get accuracyRate =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;
}

class QuestionResult {
  final String questionId;
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanation;
  final String difficulty;
  final String subject;
  final int timeSpent;

  QuestionResult({
    required this.questionId,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
    required this.difficulty,
    required this.subject,
    required this.timeSpent,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionId: json['questionId'] ?? '',
      question: json['question'] ?? '',
      userAnswer: json['userAnswer'] ?? '',
      correctAnswer: json['correctAnswer'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      explanation: json['explanation'] ?? '',
      difficulty: json['difficulty'] ?? 'Medium',
      subject: json['subject'] ?? '',
      timeSpent: json['timeSpent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'question': question,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'explanation': explanation,
      'difficulty': difficulty,
      'subject': subject,
      'timeSpent': timeSpent,
    };
  }
}

class TestStats {
  final double score;
  final DateTime date;
  final int timeSpent;

  TestStats({
    required this.score,
    required this.date,
    required this.timeSpent,
  });

  factory TestStats.fromJson(Map<String, dynamic> json) {
    return TestStats(
      score: (json['score'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      timeSpent: json['timeSpent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'date': date.toIso8601String(),
      'timeSpent': timeSpent,
    };
  }
}
