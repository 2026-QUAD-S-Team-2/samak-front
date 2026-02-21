// AIAnalysisResultResponse
class AiAnalysisResultModel {
  final int riskScore;
  final String riskLevel;
  final String message;

  const AiAnalysisResultModel({
    required this.riskScore,
    required this.riskLevel,
    required this.message,
  });

  factory AiAnalysisResultModel.fromJson(Map<String, dynamic> json) {
    return AiAnalysisResultModel(
      riskScore: json['riskScore'] as int,
      riskLevel: json['riskLevel'] as String,
      message:   json['message']   as String,
    );
  }
}