import 'dart:convert';

class Question {
  final int id;
  final String question;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.question,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var answersFromJson = json['answers'] as List;
    List<Answer> answersList = answersFromJson.map((i) => Answer.fromJson(i)).toList();

    return Question(
      id: json['id'],
      question: json['question'],
      answers: answersList,
    );
  }
}

class Answer {
  final int id;
  final int score;
  final String text;

  Answer({
    required this.id,
    required this.score,
    required this.text,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      score: json['score'],
      text: json['text'],
    );
  }
}


