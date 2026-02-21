// 이미지 업로드 관련 Repository
// POST /api/v1/images          — 단일 이미지 업로드
// POST /api/v1/images/multiple — 다중 이미지 업로드
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class ImageRepository {
  ImageRepository._();
  static final ImageRepository instance = ImageRepository._();

  /// 단일 이미지 업로드
  // [filePath]: 기기 내 파일 경로 (image_picker로 선택한 XFile.path)
  // 반환값: 서버에 저장된 이미지 파일명 (string)
  Future<String> uploadSingle(String filePath) async {
    final formData = FormData.fromMap({
      'multipartFile': await MultipartFile.fromFile(filePath),
    });
    final data = await DioClient.instance.postFormData(
      '/api/v1/images',
      formData: formData,
    );
    return data as String;
  }

  /// 다중 이미지 업로드
  // [filePaths]: 기기 내 파일 경로 목록 (image_picker로 선택한 XFile.path 리스트)
  // 반환값: 서버에 저장된 이미지 파일명 목록 (List<String>)
  Future<List<String>> uploadMultiple(List<String> filePaths) async {
    // 파일 경로 목록 → MultipartFile 목록 변환
    final files = await Future.wait(
      filePaths.map((path) => MultipartFile.fromFile(path)),
    );

    final formData = FormData.fromMap({
      'multipartFiles': files,
    });

    final data = await DioClient.instance.postFormData(
      '/api/v1/images/multiple',
      formData: formData,
    );
    return (data as List).map((e) => e as String).toList();
  }
}