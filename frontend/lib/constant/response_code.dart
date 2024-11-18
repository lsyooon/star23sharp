class ResponseCode {
  // 공통 에러
  static const String inputValidationFailed = "E0001";
  static const String unsupportedMethod = "E0002";

  // 그룹 관련 에러
  static const String groupMemberNotFound = "G0001";
  static const String groupNotFound = "G0002";
  static const String groupNoPermission = "G0003";

  // 쪽지 관련 에러
  static const String letterNotFound = "L0001";
  static const String letterNoPermission = "L0002";
  static const String letterAlreadyReported = "L0003";
  static const String unsupportedFileType = "L0004";
  static const String imageFileSaveError = "L0005";
  static const String recipientNotFound = "L0006";
  static const String invalidLatLong = "L0007";
  static const String ambiguousReceivers = "L0008";
  static const String unhandledException = "L0009";
  static const String gpuProxyConnectionError = "L0010";
  static const String treasureNoteNotFound = "L0011";
  static const String noPermissionTreasureNote = "L0012";
  static const String invalidPixelationTarget = "L0013";
  static const String gpuProxyServerError = "L0014";
  static const String invalidEmbeddingCount = "L0015";
  static const String reasonNotFound = "L0017";
  static const String invalidDateFormat = "L0018";
  static const String messageTitleTooLong = "L0019";
  static const String messageContentTooLong = "L0020";
  static const String treasureHintTooLong = "L0021";
  static const String selfAsRecipient = "L0022";
  static const String searchRangeTooWide = "L0023";
  static const String invalidImageSize = "L0024";
  static const String invalidImageType = "L0025";
  static const String harmfulImage = "L0026";

  // Member Errors
  static const String expiredToken = "M0000";
  static const String duplicateUserId = "M0001";
  static const String nicknameAlreadyExists = "M0002";
  static const String mismatchedMemberInfo = "M0004";
  static const String incorrectPassword = "M0005";
  static const String memberNotFound = "M0006";
  static const String emptyRefreshToken = "M0007";
  static const String emptyAccessToken = "M0008";
  static const String invalidToken = "M0009";
  static const String invalidDeviceToken = "M0010";
  static const String deviceTokenNotFound = "M0011";
  static const String nicbookNotFound = "M0012";
  static const String nickbookNoPermission = "M0013";
  static const String nickbookAlreadyExists = "M0014";

  // Push Notification Errors
  static const String pushNotificationFailed = "P0001";
  static const String invalidPushDeviceToken = "P0002";
  static const String expiredPushDeviceToken = "P0003";
  static const String pushAuthError = "P0005";
  static const String pushMessageTooLarge = "P0006";
  static const String notificationNotFound = "P0007";
  static const String noPermissionNotification = "P0008";
}
