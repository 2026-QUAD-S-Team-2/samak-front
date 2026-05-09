// AnalysisItemListResponse
// 분석 상태 enum
enum AnalysisStatus { pending, processing, completed, failed }

// 문자열 → enum 변환 헬퍼
AnalysisStatus _parseStatus(String? status) {
  switch (status) {
    case 'PROCESSING': return AnalysisStatus.processing;
    case 'COMPLETED':  return AnalysisStatus.completed;
    case 'FAILED':     return AnalysisStatus.failed;
    default:           return AnalysisStatus.pending;
  }
}

class AnalysisItemListModel {
  final int id;
  final String companyName;
  final String countryCode;
  final int cityId;
  final DateTime createdAt;
  final int score;
  final AnalysisStatus status;

  const AnalysisItemListModel({
    required this.id,
    required this.companyName,
    required this.countryCode,
    required this.cityId,
    required this.createdAt,
    required this.score,
    required this.status,
  });

  factory AnalysisItemListModel.fromJson(Map<String, dynamic> json) {
    final companyName =
    (json['companyName'] ?? json['comapnyName']) as String;

    return AnalysisItemListModel(
      id:          json['id']          as int,
      companyName: companyName,
      countryCode: json['countryCode'] as String,
      cityId: json['cityId']           as int,
      createdAt:   DateTime.parse(json['createdAt'] as String),
      score:       (json['score'] as num?)?.toInt() ?? 0,
      status:      _parseStatus(json['status'] as String?),
    );
  }
}