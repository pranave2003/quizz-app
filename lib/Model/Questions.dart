class Question {
  String questionText;
  List<String> options;
  int correctOption;

  Question({
    required this.questionText,
    required this.options,
    required this.correctOption,
  });

  // Convert a Question object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctOption': correctOption,
    };
  }

  // Create a Question object from Firestore map
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['questionText'],
      options: List<String>.from(map['options']),
      correctOption: map['correctOption'],
    );
  }
}
