// 서버 및 네트워크 에러를 공통으로 처리하는 예외 클래스
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic rawResponse;

  const ApiException({
    required this.message,
    this.statusCode,
    this.rawResponse
  });

  // DioException → ApiException 변환 팩토리
  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(message: '서버 응답이 늦어지고 있어요.\n잠시 후 다시 시도해 주세요.');

      case DioExceptionType.connectionError:
        return const ApiException(message: '네트워크 연결을 확인해 주세요.');

    // [MODIFIED] badResponse 케이스 재작성
// 기존: serverMessage가 있으면 statusCode와 무관하게 원문 노출
// 변경: 400만 서버 메시지 허용, 4xx/5xx는 모두 한국어 친화적 메시지 사용
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final serverMessage = e.response?.data is Map
            ? e.response?.data['message'] as String?
            : null;

        switch (statusCode) {
          case 400:
          // 400은 서버가 내려준 validation 메시지를 그대로 사용
            final msg = (serverMessage != null && serverMessage.isNotEmpty)
                ? serverMessage
                : '잘못된 요청입니다.';
            return ApiException(
              message:     msg,
              statusCode:  statusCode,
              rawResponse: e.response?.data,
            );
          case 401:
            return ApiException(
              message:    '인증이 만료되었습니다.\n다시 로그인 하세요.',
              statusCode: statusCode,
            );
          case 403:
            return ApiException(
              message:    '접근 권한이 없습니다.',
              statusCode: statusCode,
            );
          case 404:
            return ApiException(
              message:    '요청한 정보를 찾을 수 없습니다.',
              statusCode: statusCode,
            );
          case 500:
          default:
          // [KEY] 500 이상은 원문(Internal Server Error 등) 절대 노출 금지
          //       rawResponse에는 원문 보존 → 디버깅/서버 전달용으로 활용
            return ApiException(
              message:     '서버 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요.',
              statusCode:  statusCode,
              rawResponse: e.response?.data,
            );
        }

      case DioExceptionType.cancel:
        return const ApiException(message: '요청이 취소되었습니다.');

      default:
        return const ApiException(message: '알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요.');
    }
  }

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message, rawResponse: $rawResponse)';
}