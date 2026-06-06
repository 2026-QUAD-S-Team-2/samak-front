// CityListResponse
// API 실제 응답 ID에 맞게 cityKoreanNames 전체 재작성
// JP, GB, DE 도시 추가 및 영문명 역매핑 테이블 추가
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
  // 일본 (JP)
  31: '도쿄',
  32: '오사카',
  33: '후쿠오카',
  34: '삿포로',
  // 영국 (GB)
  35: '런던',
  36: '맨체스터',
  37: '에든버러',
  // 독일 (DE)
  38: '베를린',
  39: '뮌헨',
  40: '함부르크',
  41: '프랑크푸르트',
};

// [수정] 영문 도시명 → 한국어 이름 역매핑 테이블
const Map<String, String> cityEnglishToKorean = {
  // 캄보디아 (KH)
  'Phnom Penh':    '프놈펜',
  'Siem Reap':     '씨엠립',
  'Sihanoukville': '시아누크빌',
  // 베트남 (VN)
  'Ho Chi Minh City': '호찌민',
  'Hanoi':         '하노이',
  'Da Nang':       '다낭',
  // 호주 (AU)
  'Sydney':        '시드니',
  'Melbourne':     '멜버른',
  'Brisbane':      '브리즈번',
  // 캐나다 (CA)
  'Toronto':       '토론토',
  'Vancouver':     '밴쿠버',
  'Montreal':      '몬트리올',
  // 미국 (US)
  'New York':      '뉴욕',
  'Los Angeles':   '로스앤젤레스',
  'Chicago':       '시카고',
  'San Francisco': '샌프란시스코',
  'Seattle':       '시애틀',
  'Las Vegas':     '라스베이거스',
  'Miami':         '마이애미',
  'Boston':        '보스턴',
  // 일본 (JP)
  'Tokyo':         '도쿄',
  'Osaka':         '오사카',
  'Fukuoka':       '후쿠오카',
  'Sapporo':       '삿포로',
  // 영국 (GB)
  'London':        '런던',
  'Manchester':    '맨체스터',
  'Edinburgh':     '에든버러',
  // 독일 (DE)
  'Berlin':        '베를린',
  'Munich':        '뮌헨',
  'Hamburg':       '함부르크',
  'Frankfurt':     '프랑크푸르트',
};

class CityModel {
  final int id;
  final String name;

  // 영문 이름으로 한국어 이름 조회하는 정적 메서드
  static String koreanFromEnglish(String englishName) =>
      cityEnglishToKorean[englishName] ?? englishName;

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