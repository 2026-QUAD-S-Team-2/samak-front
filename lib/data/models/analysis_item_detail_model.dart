// AnalysisItemDetailResponse
import 'package:flutter/foundation.dart';
import 'analysis_item_list_model.dart';

class AnalysisItemDetailModel {
  final int id;
  final String sourceUrl;
  final String countryCode;
  final int regionId;
  final String contactType;
  final String companyName;
  final double salary;
  final AnalysisStatus status;
  final DateTime createdAt;

  const AnalysisItemDetailModel({
    required this.id,
    required this.sourceUrl,
    required this.countryCode,
    required this.regionId,
    required this.contactType,
    required this.companyName,
    required this.salary,
    required this.status,
    required this.createdAt,
  });

  factory AnalysisItemDetailModel.fromJson(Map<String, dynamic> json) {
    debugPrint('[AnalysisItemDetailModel] raw json: $json');

    return AnalysisItemDetailModel(
      id:          json['id']          as int,
      sourceUrl:   json['sourceUrl']   as String,
      countryCode: json['countryCode'] as String,
      regionId:    json['regionId']    as int,
      contactType: json['contactType'] as String,
      companyName: json['companyName'] as String,
      salary:      (json['salary'] as num).toDouble(),
      status: () {
        switch (json['status'] as String?) {
          case 'PROCESSING': return AnalysisStatus.processing;
          case 'COMPLETED':  return AnalysisStatus.completed;
          case 'FAILED':     return AnalysisStatus.failed;
          default:           return AnalysisStatus.pending;
        }
      }(),
      createdAt:   DateTime.parse(json['createdAt'] as String),
    );
  }
}