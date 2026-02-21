// TodayQuizResponse, QuizAnswerResponse
class TodayQuizModel {
  final int id;
  final String question;
  final bool answer;
  final String explanation;
  final bool isSolved;
  final bool isCorrect;

  const TodayQuizModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.explanation,
    required this.isSolved,
    required this.isCorrect,
  });

  factory TodayQuizModel.fromJson(Map<String, dynamic> json) {
    return TodayQuizModel(
      id:          json['id']          as int,
      question:    json['question']    as String,
      answer:      json['answer']      as bool,
      explanation: json['explanation'] as String,
      isSolved:    json['isSolved']    as bool,
      isCorrect:   (json['isCorrect']  as bool?) ?? false,
    );
  }
}

class QuizAnswerModel {
  final bool isCorrect;
  final bool correctAnswer;
  final String explanation;

  const QuizAnswerModel({
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuizAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuizAnswerModel(
      isCorrect:     json['isCorrect']     as bool,
      correctAnswer: json['correctAnswer'] as bool,
      explanation:   json['explanation']   as String,
    );
  }
}