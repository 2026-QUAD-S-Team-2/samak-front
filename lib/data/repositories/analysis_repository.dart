// 분석 관련 Repository
// GET    /api/v1/analysis/items
// POST   /api/v1/analysis/items
// GET    /api/v1/analysis/items/{id}/detail
// GET    /api/v1/analysis/items/{id}/country-warning
// GET    /api/v1/analysis/items/{id}/ai-analysis
import '../../core/network/dio_client.dart';
import '../models/analysis_item_create_request.dart';
import '../models/analysis_item_detail_model.dart';
import '../models/analysis_item_list_model.dart';
import '../models/ai_analysis_result_model.dart';
import '../models/country_warning_model.dart';

// 분석 목록 정렬 방식
enum AnalysisSortType {
  latest('LATEST'),
  riskScore('RISK_SCORE');

  final String value;
  const AnalysisSortType(this.value);
}

class AnalysisRepository {
  AnalysisRepository._();
  static final AnalysisRepository instance = AnalysisRepository._();

  /// 분석 아이템 목록 조회
  Future<List<AnalysisItemListModel>> getItems({
    AnalysisSortType sortType = AnalysisSortType.latest,
  }) async {
    final data = await DioClient.instance.get(
      '/api/v1/analysis/items',
      queryParameters: {'sortType': sortType.value},
    );
    return (data as List)
        .map((e) => AnalysisItemListModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 분석 아이템 등록
  Future<AnalysisItemDetailModel> createItem(
      AnalysisItemCreateRequest request,
      ) async {
    final data = await DioClient.instance.post(
      '/api/v1/analysis/items',
      data: request.toJson(),
    );
    return AnalysisItemDetailModel.fromJson(data as Map<String, dynamic>);
  }

  /// 분석 아이템 상세 조회
  Future<AnalysisItemDetailModel> getDetail(int analysisItemId) async {
    final data = await DioClient.instance.get(
      '/api/v1/analysis/items/$analysisItemId/detail',
    );
    return AnalysisItemDetailModel.fromJson(data as Map<String, dynamic>);
  }

  /// 국가 기반 경고 메시지 조회
  Future<CountryWarningModel> getCountryWarning(int analysisItemId) async {
    final data = await DioClient.instance.get(
      '/api/v1/analysis/items/$analysisItemId/country-warning',
    );
    return CountryWarningModel.fromJson(data as Map<String, dynamic>);
  }

  /// AI 분석 결과 조회
  Future<AiAnalysisResultModel> getAiAnalysis(int analysisItemId) async {
    final data = await DioClient.instance.get(
      '/api/v1/analysis/items/$analysisItemId/ai-analysis',
    );
    return AiAnalysisResultModel.fromJson(data as Map<String, dynamic>);
  }
}