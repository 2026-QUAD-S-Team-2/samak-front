// 이미지 업로드 관련 Repository
// POST /api/v1/images          — 단일 이미지 업로드
// POST /api/v1/images/multiple — 다중 이미지 업로드
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class ImageRepository {
  ImageRepository._();
  static final ImageRepository instance = ImageRepository._();

  /// 단일 이미지 업로드
  // [filePath]: 기기 내 파일 경로 (image_picker로 선택한 XFile.path)
  // 반환값: 서버에 저장된 이미지 파일명 (string)
  // data/repositories/image_repository.dart 수정 제안

  Future<String> uploadSingle(XFile xFile) async {
    final FormData formData;

    if (kIsWeb) {
      // 웹: 바이트 데이터를 읽어서 업로드
      final bytes = await xFile.readAsBytes();
      formData = FormData.fromMap({
        'multipartFile': MultipartFile.fromBytes(bytes, filename: xFile.name),
      });
    } else {
      // 모바일: 기존 방식 유지
      formData = FormData.fromMap({
        'multipartFile': await MultipartFile.fromFile(xFile.path),
      });
    }

    final data = await DioClient.instance.postFormData(
      '/api/v1/images',
      formData: formData,
    );
    return data as String;
  }

  /// 다중 이미지 업로드
  // [filePaths]: 기기 내 파일 경로 목록 (image_picker로 선택한 XFile.path 리스트)
  // 반환값: 서버에 저장된 이미지 파일명 목록 (List<String>)
  Future<List<String>> uploadMultiple(List<XFile> xFiles) async {
    final List<MultipartFile> files = [];

    for (var xFile in xFiles) {
      if (kIsWeb) {
        final bytes = await xFile.readAsBytes();
        files.add(MultipartFile.fromBytes(bytes, filename: xFile.name));
      } else {
        files.add(await MultipartFile.fromFile(xFile.path));
      }
    }

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