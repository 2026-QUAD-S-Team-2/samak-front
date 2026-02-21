// 인증 관련 Repository (POST /api/v1/auth/logout)
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/dio_client.dart';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 로그아웃 — 서버 토큰 무효화 후 로컬 저장소 초기화
  Future<void> logout() async {
    await DioClient.instance.post('/api/v1/auth/logout');

    // 로컬에 저장된 인증 정보 전체 삭제
    await Future.wait([
      _storage.delete(key: 'auth_token'),
      _storage.delete(key: 'user_id'),
      _storage.delete(key: 'user_email'),
    ]);
  }
}