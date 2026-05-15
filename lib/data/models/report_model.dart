// [ADDED] 피해 사례 관련 데이터 모델

// 정렬 기준 enum
enum ReportSortType {
  latest('LATEST'),
  mostReported('MOST_REPORTED');

  final String value;
  const ReportSortType(this.value);
}

// 검색 유형 enum
enum ReportSearchType {
  companyName('COMPANY_NAME', '회사명'),
  email('EMAIL', '이메일'),
  telegram('TELEGRAM', '텔레그램'),
  phone('PHONE', '전화');

  final String value;
  final String label;
  const ReportSearchType(this.value, this.label);
}

// GET /api/v1/reports 응답 항목 모델
class ReportListItemModel {
  final String companyName;
  final DateTime latestReportedAt;
  final int reportCount;

  const ReportListItemModel({
    required this.companyName,
    required this.latestReportedAt,
    required this.reportCount,
  });

  factory ReportListItemModel.fromJson(Map<String, dynamic> json) {
    return ReportListItemModel(
      companyName:      json['companyName']      as String,
      latestReportedAt: DateTime.parse(json['latestReportedAt'] as String),
      reportCount:      (json['reportCount'] as num).toInt(),
    );
  }
}

// POST /api/v1/reports 요청 바디 모델
class ReportCreateRequest {
  final int?         companyId;      // 선택: 서버에서 companyName으로 대체 가능
  final String       companyName;
  final String       reason;         // [MODIFIED] evidence → reason 복원 (API 명세 기준)
  // [MODIFIED] evidence 필드 제거 (API 명세에 없는 필드)
  final List<String> imageNames;
  final String       contactType;   // EMAIL | TELEGRAM | PHONE
  final String       contactValue;

  const ReportCreateRequest({
    this.companyId,
    required this.companyName,
    required this.reason,           // [MODIFIED] evidence → reason 복원
    // [MODIFIED] evidence 파라미터 제거
    required this.imageNames,
    required this.contactType,
    required this.contactValue,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'companyName':  companyName,
      'reason':       reason,       // [MODIFIED] evidence → reason 복원, API 명세 일치
      // [MODIFIED] 'evidence' 제거 (API 명세에 없는 필드)
      'imageNames':   imageNames,
      'contactType':  contactType,
      'contactValue': contactValue,
    };
    if (companyId != null) map['companyId'] = companyId;
    return map;
  }
}

// [ADDED] GET /api/v1/reports/history 응답 항목 모델
class ReportHistoryItemModel {
  final String   companyName;
  final String   identifierType;   // EMAIL | TELEGRAM | PHONE
  final String   identifierValue;
  final DateTime reportedAt;

  const ReportHistoryItemModel({
    required this.companyName,
    required this.identifierType,
    required this.identifierValue,
    required this.reportedAt,
  });

  factory ReportHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return ReportHistoryItemModel(
      companyName:     json['companyName']     as String,
      identifierType:  json['identifierType']  as String,
      identifierValue: json['identifierValue'] as String,
      reportedAt:      DateTime.parse(json['reportedAt'] as String),
    );
  }
}