// 뉴스 관련 Repository (GET /api/v1/news/banner)
import '../../core/network/dio_client.dart';
import '../models/news_model.dart';

class NewsRepository {
  NewsRepository._();
  static final NewsRepository instance = NewsRepository._();

  /// 배너 뉴스 목록 조회
  Future<List<NewsModel>> getBannerNews() async {
    final data = await DioClient.instance.get('/api/v1/news/banner');
    return (data as List)
        .map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}