class ChatMessage {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final String? contentUrdu;
  final DateTime timestamp;
  final bool isLoading;
  final bool isError;
  final List<String> suggestions;
  final List<String> dataUsed;
  final List<String> risksWarnings;
  final List<String> nextSteps;
  final List<String> sourceLabels;
  final String? directAnswer;
  final String? explanation;
  final String? recommendation;
  final String? confidenceLevel;
  final String? warning;
  final String? imageBase64;
  final Map<String, dynamic>? imageAnalysis;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.contentUrdu,
    required this.timestamp,
    this.isLoading = false,
    this.isError = false,
    this.suggestions = const [],
    this.dataUsed = const [],
    this.risksWarnings = const [],
    this.nextSteps = const [],
    this.sourceLabels = const [],
    this.directAnswer,
    this.explanation,
    this.recommendation,
    this.confidenceLevel,
    this.warning,
    this.imageBase64,
    this.imageAnalysis,
  });

  ChatMessage copyWith({
    String? content,
    String? contentUrdu,
    bool? isLoading,
    bool? isError,
    List<String>? suggestions,
    List<String>? dataUsed,
    List<String>? risksWarnings,
    List<String>? nextSteps,
    List<String>? sourceLabels,
    String? directAnswer,
    String? explanation,
    String? recommendation,
    String? confidenceLevel,
    String? warning,
    Map<String, dynamic>? imageAnalysis,
  }) =>
      ChatMessage(
        id: id,
        role: role,
        content: content ?? this.content,
        contentUrdu: contentUrdu ?? this.contentUrdu,
        timestamp: timestamp,
        isLoading: isLoading ?? this.isLoading,
        isError: isError ?? this.isError,
        suggestions: suggestions ?? this.suggestions,
        dataUsed: dataUsed ?? this.dataUsed,
        risksWarnings: risksWarnings ?? this.risksWarnings,
        nextSteps: nextSteps ?? this.nextSteps,
        sourceLabels: sourceLabels ?? this.sourceLabels,
        directAnswer: directAnswer ?? this.directAnswer,
        explanation: explanation ?? this.explanation,
        recommendation: recommendation ?? this.recommendation,
        confidenceLevel: confidenceLevel ?? this.confidenceLevel,
        warning: warning ?? this.warning,
        imageBase64: imageBase64,
        imageAnalysis: imageAnalysis ?? this.imageAnalysis,
      );

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}
