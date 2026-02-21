// 퀴즈 관련 Repository
// GET  /api/v1/quizzes/today
// POST /api/v1/quizzes/today/answer
import '../../core/network/dio_client.dart';
import '../models/quiz_model.dart';

class QuizRepository {
  QuizRepository._();
  static final QuizRepository instance = QuizRepository._();

  /// 오늘의 퀴즈 조회
  Future<TodayQuizModel> getTodayQuiz() async {
    final data = await DioClient.instance.get('/api/v1/quizzes/today');
    return TodayQuizModel.fromJson(data as Map<String, dynamic>);
  }

  /// 오늘의 퀴즈 답변 제출
  // [answer]: 사용자가 선택한 O(true) / X(false)
  Future<QuizAnswerModel> submitAnswer(bool answer) async {
    final data = await DioClient.instance.post(
      '/api/v1/quizzes/today/answer',
      data: {'answer': answer},
    );
    return QuizAnswerModel.fromJson(data as Map<String, dynamic>);
  }
}