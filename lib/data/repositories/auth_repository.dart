// 인증 관련 Repository (POST /api/v1/auth/logout)
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  // [MODIFIED] 웹 스토리지 옵션 추가
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    webOptions: WebOptions(dbName: 'samak_db', publicKey: 'samak_key'),
  );

  /// 로그아웃 — 서버 토큰 무효화 후 로컬 저장소 초기화
  Future<void> logout() async {
    try {
      await DioClient.instance.post('/api/v1/auth/logout');
    } catch (e) {
    }

    // 로컬에 저장된 인증 정보 전체 삭제
    await Future.wait([
      _storage.delete(key: 'auth_token'),
      _storage.delete(key: 'user_id'),
      _storage.delete(key: 'user_email'),
    ]);
  }
}