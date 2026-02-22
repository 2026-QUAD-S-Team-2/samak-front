// CountryWarningResponse
class CountryWarningModel {
  final String warningMessage;

  const CountryWarningModel({required this.warningMessage});

  factory CountryWarningModel.fromJson(Map<String, dynamic> json) {
    return CountryWarningModel(
      warningMessage: json['warningMessage'] as String,
    );
  }
}