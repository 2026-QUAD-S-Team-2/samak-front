// CityListResponse
// [수정] API 실제 응답 ID에 맞게 cityKoreanNames 전체 재작성
const Map<int, String> cityKoreanNames = {
  // 캄보디아 (KH)
  1: '프놈펜',
  2: '씨엠립',
  3: '시아누크빌',
  // 베트남 (VN)
  4: '호찌민',
  5: '하노이',
  6: '다낭',
  // 호주 (AU)
  7: '시드니',
  8: '멜버른',
  9: '브리즈번',
  // 캐나다 (CA)
  10: '토론토',
  11: '밴쿠버',
  12: '몬트리올',
  // 미국 (US)
  23: '뉴욕',
  24: '로스앤젤레스',
  25: '시카고',
  26: '샌프란시스코',
  27: '시애틀',
  28: '라스베이거스',
  29: '마이애미',
  30: '보스턴',
};

class CityModel {
  final int id;
  final String name;

  const CityModel({
    required this.id,
    required this.name,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id:   json['id']   as int,
      name: json['name'] as String,
    );
  }

  // 한국어 이름 반환
  String get displayName => cityKoreanNames[id] ?? name;

  // id만으로 한국어 이름 조회하는 정적 메서드
  static String nameFromId(int id, {String fallback = ''}) =>
      cityKoreanNames[id] ?? fallback;
}