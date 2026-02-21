// GET api/members/me
import '../../core/network/dio_client.dart';
import '../models/member_model.dart';

class MemberRepository {
  MemberRepository._();
  static final MemberRepository instance = MemberRepository._();

  /// 내 정보 조회
  Future<MemberModel> getMe() async {
    final data = await DioClient.instance.get('/api/members/me');
    return MemberModel.fromJson(data as Map<String, dynamic>);
  }
}