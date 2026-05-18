// AIAnalysisResultResponse

// [ADDED] location 모델
class AiAnalysisLocationModel {
  final String rawText;
  final double lat;
  final double lng;
  final String adminLevel;
  final double zoom;
  final String status;

  const AiAnalysisLocationModel({
    required this.rawText,
    required this.lat,
    required this.lng,
    required this.adminLevel,
    required this.zoom,
    required this.status,
  });

  factory AiAnalysisLocationModel.fromJson(Map<String, dynamic> json) {
    return AiAnalysisLocationModel(
      rawText:    json['rawText']    as String,
      lat:        (json['lat']       as num).toDouble(),
      lng:        (json['lng']       as num).toDouble(),
      adminLevel: json['adminLevel'] as String,
      zoom:       (json['zoom']      as num).toDouble(),
      status:     json['status']     as String,
    );
  }
}

class AiAnalysisResultModel {
  final int riskScore;
  final String riskLevel;
  final String message;
  final AiAnalysisLocationModel? location;

  const AiAnalysisResultModel({
    required this.riskScore,
    required this.riskLevel,
    required this.message,
    this.location
  });

  factory AiAnalysisResultModel.fromJson(Map<String, dynamic> json) {
    return AiAnalysisResultModel(
      riskScore: (json['riskScore'] as num).toInt(),
      riskLevel: json['riskLevel'] as String,
      message:   json['message']   as String,
      location: json['location'] != null
          ? AiAnalysisLocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }
}