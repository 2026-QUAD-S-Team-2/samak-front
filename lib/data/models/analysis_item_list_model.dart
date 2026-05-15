// AnalysisItemListResponse
enum AnalysisStatus { pending, processing, completed, failed }

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
  final String countryName; // [수정] countryCode(String) → countryName(String)
  final String cityName;    // [수정] cityId(int) → cityName(String)
  final DateTime createdAt;
  final int score;
  final AnalysisStatus status;

  const AnalysisItemListModel({
    required this.id,
    required this.companyName,
    required this.countryName, // [수정]
    required this.cityName,    // [수정]
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
      countryName: json['countryName'] as String, // [수정]
      cityName:    json['cityName']    as String, // [수정]
      createdAt:   DateTime.parse(json['createdAt'] as String),
      score:       (json['score'] as num?)?.toInt() ?? 0,
      status:      _parseStatus(json['status'] as String?),
    );
  }
}