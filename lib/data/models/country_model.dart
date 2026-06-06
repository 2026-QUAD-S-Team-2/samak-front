// CountryListResponse
// 국가 코드 → 한국어 이름 매핑 테이블

// [수정] API에 KR 없으므로 제거
const Map<String, String> countryKoreanNames = {
  'KH': '캄보디아',
  'VN': '베트남',
  'AU': '호주',
  'CA': '캐나다',
  'US': '미국',
  'JP': '일본',
  'GB': '영국',
  'DE': '독일',
};

// 영문 국가명 → 한국어 이름 역매핑 테이블
const Map<String, String> countryEnglishToKorean = {
  'Cambodia':       '캄보디아',
  'Vietnam':        '베트남',
  'Australia':      '호주',
  'Canada':         '캐나다',
  'United States':  '미국',
  'Japan':          '일본',
  'United Kingdom': '영국',
  'Germany':        '독일',
};

class CountryModel {
  final String code;
  final String name;

  // 영문 이름으로 한국어 이름 조회하는 정적 메서드
  static String koreanFromEnglish(String englishName) =>
      countryEnglishToKorean[englishName] ?? englishName;

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