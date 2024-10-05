// lib/Model/Question.dart

class Question {
  final String questionText;
  final List<String> options;
  final int correctOption;
  final String date;

  Question({
    required this.questionText,
    required this.options,
    required this.correctOption,
    required this.date,
  });

  // Convert a Question object to a map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctOption': correctOption,
      'date': date,
    };
  }

  // Create a Question object from a map (Firestore data)
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOption: map['correctOption'] ?? 0,
      date: map['date'] ?? '',
    );
  }
}
