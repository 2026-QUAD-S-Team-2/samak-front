// CityListResponse
// 도시 id → 한국어 이름 매핑 테이블
const Map<int, String> cityKoreanNames = {
  // 미국
  9:  '뉴욕',
  10: '로스앤젤레스',
  11: '시카고',
  12: '휴스턴',
  13: '피닉스',
  14: '필라델피아',
  15: '샌안토니오',
  16: '샌디에이고',
  17: '댈러스',
  18: '새너제이',
  // 베트남
  19: '하노이',
  20: '호찌민',
  21: '다낭',
  // 캄보디아
  22: '프놈펜',
  23: '씨엠립',
  24: '밧탐방',
  // 캐나다
  25: '토론토',
  26: '밴쿠버',
  27: '몬트리올',
  28: '캘거리',
  29: '오타와',
  // 호주
  30: '시드니',
  31: '멜버른',
  32: '브리즈번',
  33: '퍼스',
  34: '캔버라',
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