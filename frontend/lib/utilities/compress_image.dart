import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:star23sharp/main.dart';

Future<File> compressImage(File file, {int quality = 95}) async {
  try {
    final fileName = path.basename(file.path);
    if (!fileName.endsWith('.jpg') &&
        !fileName.endsWith('.jpeg') &&
        !fileName.endsWith('.png')) {
      throw Exception("지원되지 않는 파일 형식: $fileName");
    }
    // 임시 디렉토리 경로 가져오기
    final directory = await getTemporaryDirectory();

    // 파일 이름이 .jpg 또는 .jpeg로 끝나지 않을 경우 .jpg로 변경
    String targetName = path.basename(file.path);
    if (!targetName.endsWith('.jpg') && !targetName.endsWith('.jpeg')) {
      targetName = '${path.basenameWithoutExtension(file.path)}.jpg';
    }

    // 압축된 파일 저장 경로
    final targetPath = path.join(directory.path, "compressed_$targetName");

    // 파일 압축 시작
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, // 원본 파일 경로
      targetPath, // 압축된 파일 저장 경로
      quality: quality, // 압축 품질
    );

    // 압축 결과 처리
    if (result != null) {
      logger.d(
          "압축 성공: 원본 파일 크기: ${file.lengthSync()} 바이트, 압축 파일 크기: ${File(result.path).lengthSync()} 바이트");
      return File(result.path);
    } else {
      throw Exception("이미지 압축 실패: 결과 파일이 null입니다.");
    }
  } catch (e) {
    // 에러 처리
    logger.e("이미지 압축 중 오류 발생: $e");
    return file; // 실패 시 원본 파일 반환
  }
}
