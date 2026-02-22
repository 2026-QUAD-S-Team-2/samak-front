// CountryListResponse
// 국가 코드 → 한국어 이름 매핑 테이블
const Map<String, String> _countryKoreanNames = {
  'KR': '대한민국',
  'US': '미국',
  'VN': '베트남',
  'KH': '캄보디아',
  'CA': '캐나다',
  'AU': '호주',
};

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

  // 한국어 이름 반환
  String get displayName => _countryKoreanNames[code] ?? name;
}