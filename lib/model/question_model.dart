class QuestionModel {
  String? question;
  Map<String, bool>? answers;
  QuestionModel(this.question, this.answers);
}

class Question {
    final String question;
    final Map<String, bool> answers;

    Question({
      required this.question,
      required this.answers,
    });

    factory Question.fromJson(Map<String, dynamic> json) {
      return Question(
        question: json['question'],
        answers: Map.from((json['incorrect_answers'] as Map<String, dynamic>)
            .entries
            .map((entry) => MapEntry(entry.key, entry.value as bool)) as Map),
      );
    }
  }