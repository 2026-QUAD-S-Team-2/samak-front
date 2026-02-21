//AnalysisItemCreateRequest
class AnalysisItemCreateRequest {
  final List<String> imageNames;
  final String companyName;
  final String countryCode;
  final int cityId;
  final String contactType;
  final String sourceUrl;
  final String notes;
  final int salary;

  const AnalysisItemCreateRequest({
    required this.imageNames,
    required this.companyName,
    required this.countryCode,
    required this.cityId,
    required this.contactType,
    required this.sourceUrl,
    required this.notes,
    required this.salary,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageNames':   imageNames,
      'companyName':  companyName,
      'countryCode':  countryCode,
      'cityId':       cityId,
      'contactType':  contactType,
      'sourceUrl':    sourceUrl,
      'notes':        notes,
      'salary':       salary,
    };
  }
}