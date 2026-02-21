// AnalysisItemListResponse
class AnalysisItemListModel {
  final int id;
  final String companyName;
  final String countryCode;
  final DateTime createdAt;
  final int score;

  const AnalysisItemListModel({
    required this.id,
    required this.companyName,
    required this.countryCode,
    required this.createdAt,
    required this.score,
  });

  factory AnalysisItemListModel.fromJson(Map<String, dynamic> json) {
    final companyName =
    (json['companyName'] ?? json['comapnyName']) as String;

    return AnalysisItemListModel(
      id:          json['id']          as int,
      companyName: companyName,
      countryCode: json['countryCode'] as String,
      createdAt:   DateTime.parse(json['createdAt'] as String),
      score:       (json['score'] as num).toInt(),
    );
  }
}