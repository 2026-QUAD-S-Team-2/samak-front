// CountryListResponse
class CountryModel {
  final String code;
  final String name;

  const CountryModel({
    required this.code,
    required this.name,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }
}