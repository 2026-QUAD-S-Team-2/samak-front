// CountryListResponse
// 국가 코드 → 한국어 이름 매핑 테이블

// [수정] API에 KR 없으므로 제거
const Map<String, String> countryKoreanNames = {
  'KH': '캄보디아',
  'VN': '베트남',
  'AU': '호주',
  'CA': '캐나다',
  'US': '미국',
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
  String get displayName => countryKoreanNames[code] ?? name;

  // 코드만으로 한국어 이름 조회하는 메서드
  static String nameFromCode(String code) => countryKoreanNames[code] ?? code;
}