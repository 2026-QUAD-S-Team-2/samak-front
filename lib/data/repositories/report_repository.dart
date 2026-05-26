// [ADDED] 피해 사례 관련 Repository
// GET  /api/v1/reports — 신고 목록 조회
// POST /api/v1/reports — 신고 등록
import '../../core/network/dio_client.dart';
import '../models/report_model.dart';

class ReportRepository {
  ReportRepository._();
  static final ReportRepository instance = ReportRepository._();

  /// 신고 목록 조회
  /// [searchType] 검색 유형 (keyword가 없으면 전송하지 않음)
  /// [sortType]   정렬 기준
  /// [keyword]    검색어
  Future<List<ReportListItemModel>> getReports({
    ReportSearchType? searchType,
    ReportSortType    sortType = ReportSortType.mostReported,
    String?           keyword,
  }) async {
    final params = <String, dynamic>{'sortType': sortType.value};
    if (keyword != null && keyword.isNotEmpty) {
      params['keyword'] = keyword;
      if (searchType != null) params['searchType'] = searchType.value;
    }

    final data = await DioClient.instance.get(
      '/api/v1/reports',
      queryParameters: params,
    );
    return (data as List)
        .map((e) => ReportListItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 신고 등록
  /// 반환값: 생성된 신고 id
  Future<int> createReport(ReportCreateRequest request) async {
    final data = await DioClient.instance.post(
      '/api/v1/reports',
      data: request.toJson(),
    );
    return (data as Map<String, dynamic>)['id'] as int;
  }

  // [ADDED] 신고 이력 조회 — 채용 공고 분석 결과 화면의 '신고 이력' 섹션에서 사용
  // GET /api/v1/reports/history
  Future<List<ReportHistoryItemModel>> getReportHistory({
    String? companyName,
    String? identifierType,
    String? identifierValue,
  }) async {
    final params = <String, dynamic>{};
    if (companyName     != null) params['companyName']     = companyName;
    if (identifierType  != null) params['identifierType']  = identifierType;
    if (identifierValue != null) params['identifierValue'] = identifierValue;

    final data = await DioClient.instance.get(
      '/api/v1/reports/history',
      queryParameters: params,
    );
    return (data as List)
        .map((e) => ReportHistoryItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // [ADDED] 신고 상세 조회 — GET /api/v1/reports/detail
  Future<ReportDetailModel> getReportDetail({
    required String companyName,
  }) async {
    final data = await DioClient.instance.get(
      '/api/v1/reports/detail',
      queryParameters: {'companyName': companyName},
    );
    return ReportDetailModel.fromJson(data as Map<String, dynamic>);
  }
}