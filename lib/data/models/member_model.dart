// MemberResponse
class MemberModel {
  final int id;
  final String email;
  final String nickname;
  final String? profileImageUrl;
  final bool isOnboarded;

  const MemberModel({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
    required this.isOnboarded,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id:              json['id']              as int,
      email:           (json['email']           as String?) ?? '',
      nickname:        (json['nickname']        as String?) ?? '사용자',
      profileImageUrl: json['profileImageUrl'] as String?,
      isOnboarded:     (json['isOnboarded']     as bool?) ?? false,
    );
  }
  // 디버깅 용 코드
  // @override
  // String toString() =>
  //     'MemberModel(id: $id, email: $email, nickname: $nickname, isOnboarded: $isOnboarded)';
}