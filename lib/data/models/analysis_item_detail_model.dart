// AnalysisItemDetailResponse
class AnalysisItemDetailModel {
  final int id;
  final String sourceUrl;
  final String countryCode;
  final int regionId;
  final String contactType;
  final String companyName;
  final int salary;
  final DateTime createdAt;

  const AnalysisItemDetailModel({
    required this.id,
    required this.sourceUrl,
    required this.countryCode,
    required this.regionId,
    required this.contactType,
    required this.companyName,
    required this.salary,
    required this.createdAt,
  });

  factory AnalysisItemDetailModel.fromJson(Map<String, dynamic> json) {
    return AnalysisItemDetailModel(
      id:          json['id']          as int,
      sourceUrl:   json['sourceUrl']   as String,
      countryCode: json['countryCode'] as String,
      regionId:    json['regionId']    as int,
      contactType: json['contactType'] as String,
      companyName: json['companyName'] as String,
      salary:      json['salary']      as int,
      createdAt:   DateTime.parse(json['createdAt'] as String),
    );
  }
}