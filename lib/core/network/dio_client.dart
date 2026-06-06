// Dio 싱글톤 클라이언트. auth_token 자동 주입 인터셉터 포함.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_exception.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DioClient {
  DioClient._();

  static final DioClient instance = DioClient._();

  static const String _baseUrl = 'https://samak.mooo.com';
  static const Duration _connectTimeout = Duration(seconds: 10);
  static const Duration _receiveTimeout = Duration(seconds: 15);

  // [MODIFIED] 웹 스토리지 옵션 추가
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    webOptions: WebOptions(dbName: 'samak_db', publicKey: 'samak_key'),
  );

  // Dio 인스턴스 지연 초기화
  late final Dio _dio = _buildDio();

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // 요청 인터셉터: auth_token이 존재하면 Authorization 헤더 자동 주입
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) options.headers['Authorization'] = 'Bearer $token';

          // 서버가 에러 원인 파악에 활용할 수 있는 메타데이터
          final info = await PackageInfo.fromPlatform();
          options.headers['X-App-Version']  = info.version;        // ex) "1.2.3"
          options.headers['X-Build-Number'] = info.buildNumber;    // ex) "45"
          options.headers['X-Platform'] = kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase();
          options.headers['X-Request-Id']   = DateTime.now().millisecondsSinceEpoch.toString(); // 요청 추적용

          return handler.next(options);
        },

        // 응답 인터셉터: 서버 공통 포맷 { code, message, data } 에서 data 추출
        onResponse: (response, handler) {
          return handler.next(response);
        },

        // 에러 인터셉터: DioException → ApiException 변환
        onError: (DioException error, handler) {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: ApiException.fromDioException(error),
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );

    return dio;
  }

  // 공통 요청 메서드 (GET / POST / PUT / DELETE)
  // 반환 타입: 서버 응답의 data 필드

  // GET 요청
  Future<dynamic> get(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _extractData(response);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  // POST 요청 (application/json)
  Future<dynamic> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _extractData(response);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  // POST 요청 (multipart/form-data) — 이미지 업로드 전용
  Future<dynamic> postFormData(
      String path, {
        required FormData formData,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return _extractData(response);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  // PUT 요청
  Future<dynamic> put(
      String path, {
        dynamic data,
      }) async {
    try {
      final response = await _dio.put(path, data: data);
      return _extractData(response);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  // DELETE 요청
  Future<dynamic> delete(
      String path, {
        dynamic data,
      }) async {
    try {
      final response = await _dio.delete(path, data: data);
      return _extractData(response);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  // 내부 헬퍼

  // 서버 응답 { code, message, data } 에서 data 추출
  dynamic _extractData(Response response) {
    final body = response.data;
    if (body is Map && body.containsKey('data')) {
      return body['data'];
    }
    // data 키가 없는 경우 전체 body 반환 (예: 로그아웃 등 빈 응답)
    return body;
  }

  // DioException의 error 필드가 ApiException이면 그대로 반환, 아니면 새로 변환
  ApiException _toApiException(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    return ApiException.fromDioException(e);
  }
}