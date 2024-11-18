import 'package:star23sharp/constant/index.dart';
import 'package:star23sharp/models/index.dart';

enum DataSource {
  // Success
  success,
  noContent,

  // Common Errors
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  serverError,
  invalidData,

  // Custom Errors - Group (G)
  groupMemberNotFound,
  groupNotFound,
  groupNoPermission,

  // Custom Errors - Letter (L)
  letterNotFound,
  letterNoPermission,
  letterAlreadyReported,
  unsupportedFileType,
  invalidLatitudeLongitude,
  ambiguousReceivers,
  messageTitleTooLong,
  messageContentTooLong,
  treasureHintTooLong,
  selfAsRecipient,
  unknownError,

  // Custom Errors - Member (M)
  expiredToken,
  duplicateUserId,
  nicknameAlreadyExists,
  mismatchedMemberInfo,
  invalidToken,
  deviceTokenNotFound,

  // Custom Errors - Push Notifications (P)
  pushNotificationFailed,
  invalidDeviceToken,
  pushAuthError,
  pushMessageTooLarge,
}

extension DataSourceExtension on String {
  ResponseModel getFailure() {
    switch (this) {
      // Common Errors
      case ResponseCode.inputValidationFailed:
        return ResponseModel(
          code: ResponseCode.inputValidationFailed,
          message: "입력값이 필수 조건에 만족하지 않습니다.",
        );
      case ResponseCode.unsupportedMethod:
        return ResponseModel(
          code: ResponseCode.unsupportedMethod,
          message: "지원하지 않는 메서드입니다.",
        );

      // Group Errors
      case ResponseCode.groupMemberNotFound:
        return ResponseModel(
          code: ResponseCode.groupMemberNotFound,
          message: "그룹 멤버 중 일부가 존재하지 않거나 비활성 상태입니다.",
        );
      case ResponseCode.groupNotFound:
        return ResponseModel(
          code: ResponseCode.groupNotFound,
          message: "지정된 그룹이 존재하지 않습니다.",
        );
      case ResponseCode.groupNoPermission:
        return ResponseModel(
          code: ResponseCode.groupNoPermission,
          message: "그룹에 대한 접근 권한이 없습니다.",
        );

      // Letter Errors
      case ResponseCode.letterNotFound:
        return ResponseModel(
          code: ResponseCode.letterNotFound,
          message: "쪽지가 존재하지 않습니다.",
        );
      case ResponseCode.letterNoPermission:
        return ResponseModel(
          code: ResponseCode.letterNoPermission,
          message: "쪽지에 접근할 권한이 없습니다.",
        );
      case ResponseCode.letterAlreadyReported:
        return ResponseModel(
          code: ResponseCode.letterAlreadyReported,
          message: "이미 신고된 쪽지입니다.",
        );
      case ResponseCode.unsupportedFileType:
        return ResponseModel(
          code: ResponseCode.unsupportedFileType,
          message: "지원하지 않는 파일 형식입니다.",
        );
      case ResponseCode.imageFileSaveError:
        return ResponseModel(
          code: ResponseCode.imageFileSaveError,
          message: "이미지 파일 저장 중 오류가 발생했습니다.",
        );
      case ResponseCode.recipientNotFound:
        return ResponseModel(
          code: ResponseCode.recipientNotFound,
          message: "수신자가 존재하지 않습니다.",
        );
      case ResponseCode.invalidLatLong:
        return ResponseModel(
          code: ResponseCode.invalidLatLong,
          message: "위도와 경도 값이 유효하지 않습니다.",
        );
      case ResponseCode.ambiguousReceivers:
        return ResponseModel(
          code: ResponseCode.ambiguousReceivers,
          message: "수신 대상이 불분명합니다.",
        );
      case ResponseCode.unhandledException:
        return ResponseModel(
          code: ResponseCode.unhandledException,
          message: "기타 예외 미처리 에러입니다.",
        );
      case ResponseCode.gpuProxyConnectionError:
        return ResponseModel(
          code: ResponseCode.gpuProxyConnectionError,
          message: "GPU 프록시 서버 연결 오류가 발생했습니다.",
        );
      case ResponseCode.treasureNoteNotFound:
        return ResponseModel(
          code: ResponseCode.treasureNoteNotFound,
          message: "존재하지 않는 보물 쪽지입니다.",
        );
      case ResponseCode.noPermissionTreasureNote:
        return ResponseModel(
          code: ResponseCode.noPermissionTreasureNote,
          message: "열람 권한이 없는 보물 쪽지입니다.",
        );
      case ResponseCode.invalidPixelationTarget:
        return ResponseModel(
          code: ResponseCode.invalidPixelationTarget,
          message: "픽셀화 대상이 잘못되었습니다.",
        );
      case ResponseCode.gpuProxyServerError:
        return ResponseModel(
          code: ResponseCode.gpuProxyServerError,
          message: "GPU 프록시 서버 오류가 발생했습니다.",
        );
      case ResponseCode.invalidEmbeddingCount:
        return ResponseModel(
          code: ResponseCode.invalidEmbeddingCount,
          message: "임베딩 개수가 유효하지 않습니다.",
        );
      case ResponseCode.reasonNotFound:
        return ResponseModel(
          code: ResponseCode.reasonNotFound,
          message: "해당 신고 사유를 찾을 수 없습니다.",
        );
      case ResponseCode.invalidDateFormat:
        return ResponseModel(
          code: ResponseCode.invalidDateFormat,
          message: "날짜 형식이 올바르지 않습니다.",
        );
      case ResponseCode.messageTitleTooLong:
        return ResponseModel(
          code: ResponseCode.messageTitleTooLong,
          message: "쪽지 제목이 너무 깁니다.",
        );
      case ResponseCode.messageContentTooLong:
        return ResponseModel(
          code: ResponseCode.messageContentTooLong,
          message: "쪽지 내용이 너무 깁니다.",
        );
      case ResponseCode.treasureHintTooLong:
        return ResponseModel(
          code: ResponseCode.treasureHintTooLong,
          message: "보물 쪽지 힌트가 너무 깁니다.",
        );
      case ResponseCode.selfAsRecipient:
        return ResponseModel(
          code: ResponseCode.selfAsRecipient,
          message: "수신자 목록에 본인을 포함할 수 없습니다.",
        );
      case ResponseCode.searchRangeTooWide:
        return ResponseModel(
          code: ResponseCode.searchRangeTooWide,
          message: "검색 범위가 너무 넓습니다.",
        );

      // Member Errors
      case ResponseCode.expiredToken:
        return ResponseModel(
          code: ResponseCode.expiredToken,
          message: "세션이 만료되어 다시 로그인 해주세요.", // 만료된 토큰입니다
        );
      case ResponseCode.duplicateUserId:
        return ResponseModel(
          code: ResponseCode.duplicateUserId,
          message: "이미 사용된 회원 ID입니다.",
        );
      case ResponseCode.nicknameAlreadyExists:
        return ResponseModel(
          code: ResponseCode.nicknameAlreadyExists,
          message: "이미 존재하는 닉네임입니다.",
        );
      case ResponseCode.mismatchedMemberInfo:
        return ResponseModel(
          code: ResponseCode.mismatchedMemberInfo,
          message: "회원 정보가 일치하지 않습니다.",
        );
      case ResponseCode.incorrectPassword:
        return ResponseModel(
          code: ResponseCode.incorrectPassword,
          message: "현재 비밀번호가 일치하지 않습니다.",
        );
      case ResponseCode.memberNotFound:
        return ResponseModel(
          code: ResponseCode.memberNotFound,
          message: "회원이 존재하지 않습니다.",
        );
      case ResponseCode.emptyRefreshToken:
        return ResponseModel(
          code: ResponseCode.emptyRefreshToken,
          message: "Refresh Token이 비어있습니다.",
        );
      case ResponseCode.emptyAccessToken:
        return ResponseModel(
          code: ResponseCode.emptyAccessToken,
          message: "Access Token이 비어있습니다.",
        );
      case ResponseCode.invalidToken:
        return ResponseModel(
          code: ResponseCode.invalidToken,
          message: "유효하지 않은 토큰입니다.",
        );
      case ResponseCode.invalidDeviceToken:
        return ResponseModel(
          code: ResponseCode.invalidDeviceToken,
          message: "잘못된 디바이스 토큰입니다.",
        );
      case ResponseCode.deviceTokenNotFound:
        return ResponseModel(
          code: ResponseCode.deviceTokenNotFound,
          message: "디바이스 토큰을 찾을 수 없습니다.",
        );

      // Push Notification Errors
      case ResponseCode.pushNotificationFailed:
        return ResponseModel(
          code: ResponseCode.pushNotificationFailed,
          message: "푸시 알림 전송에 실패했습니다.",
        );
      case ResponseCode.invalidPushDeviceToken:
        return ResponseModel(
          code: ResponseCode.invalidPushDeviceToken,
          message: "유효하지 않은 디바이스 토큰입니다.",
        );
      case ResponseCode.expiredPushDeviceToken:
        return ResponseModel(
          code: ResponseCode.expiredPushDeviceToken,
          message: "세션이 만료되어 다시 로그인 해주세요.", // 만료된 디바이스 토큰입니다ㅁㅁ
        );
      case ResponseCode.pushAuthError:
        return ResponseModel(
          code: ResponseCode.pushAuthError,
          message: "푸시 알림 인증 오류가 발생했습니다.",
        );
      case ResponseCode.pushMessageTooLarge:
        return ResponseModel(
          code: ResponseCode.pushMessageTooLarge,
          message: "푸시 알림 메시지 크기가 초과되었습니다.",
        );
      case ResponseCode.notificationNotFound:
        return ResponseModel(
          code: ResponseCode.notificationNotFound,
          message: "알림이 존재하지 않습니다.",
        );
      case ResponseCode.noPermissionNotification:
        return ResponseModel(
          code: ResponseCode.noPermissionNotification,
          message: "알림에 접근할 권한이 없습니다.",
        );

      // Default Error
      default:
        return ResponseModel(
          code: "UNKNOWN",
          message: "알 수 없는 오류가 발생했습니다.",
        );
    }
  }
}
