from fastapi import status

from .response_model import ResponseModel


class AppException(Exception):
    status_code: int
    code: str

    def to_response_model(self, message=None, data=None):
        msg = None
        if len(self.args) > 0:
            msg = str(self.args[0])
        else:
            msg = (
                message
                if message is not None
                else "에러 코드 " + self.code + " 를 참조하세요."
            )
        return ResponseModel(
            code=self.code,
            message=msg,
            data=data,
        )

    @classmethod
    def construct(cls, status_code: int, code: str):
        obj = cls()
        obj.status_code = status_code
        obj.code = code
        return obj


class InvalidInputException(AppException):
    """
    입력값이 필수 조건에 만족하지 않습니다.
    """

    status_code = status.HTTP_400_BAD_REQUEST
    code = "E0001"


class InvalidGroupMembersException(AppException):
    """
    새로 생성중인 그룹의 멤버로 지정된 멤버들 중 일부가 존재하지 않거나 비활성 상태입니다.
    """

    status_code = status.HTTP_400_BAD_REQUEST
    code = "G0001"


class GroupNotFoundException(AppException):
    """
    지정된 id에 해당하는 그룹이 존재하지 않습니다.
    """

    status_code = status.HTTP_404_NOT_FOUND
    code = "G0002"


class UnsupportedFileTypeException(AppException):
    """
    지원하지 않는 파일 형식입니다.
    """

    status_code = status.HTTP_415_UNSUPPORTED_MEDIA_TYPE
    code = "L0004"


class ImageSaveException(AppException):
    """
    이미지 저장 중 오류
    """

    status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    code = "L0005"


class RecipientNotFoundException(AppException):
    """
    수신자가 존재하지 않습니다.
    """

    status_code = status.HTTP_404_NOT_FOUND
    code = "L0006"


class InvalidCoordinatesException(AppException):
    """
    위도, 경도값이 유효하지 않습니다.
    """

    status_code = status.HTTP_400_BAD_REQUEST
    code = "L0007"


class AmbiguousTargetException(AppException):
    """
    수신 대상이 불분명합니다.
    """

    status_code = status.HTTP_400_BAD_REQUEST
    code = "L0008"


class UnhandledException(AppException):
    """
    기타 예외 미처리 에러
    """

    status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    code = "L0009"


class GPUProxyConnectionException(AppException):
    """
    GPU 프록시 서버 연결 오류
    """

    status_code = status.HTTP_502_BAD_GATEWAY
    code = "L0010"


class TreasureNotFoundException(AppException):
    """
    존재하지 않는 보물 쪽지입니다.
    """

    status_code = status.HTTP_404_NOT_FOUND
    code = "L0011"


class UnauthorizedTreasureAccessException(AppException):
    """
    열람 권한이 없는 보물 쪽지입니다.
    """

    status_code = status.HTTP_401_UNAUTHORIZED
    code = "L0012"


class InvalidPixelTargetException(AppException):
    """
    픽셀화 대상이 잘못되었습니다.
    """

    status_code = status.HTTP_400_BAD_REQUEST
    code = "L0013"


class GPUProxyServerException(AppException):
    """
    GPU 프록시 서버 오류
    """

    status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    code = "L0014"


class EmbeddingsCountMismatchException(AppException):
    """
    GPU 서버에서 얻은 임베딩의 개수가 2개가 아닙니다
    """

    status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    code = "L0015"


class MemberNotFoundException(AppException):
    """
    회원이 존재하지 않습니다.
    """

    status_code = status.HTTP_404_NOT_FOUND
    code = "M0006"


class InvalidTokenException(AppException):
    """
    유효하지 않은 토큰이거나 인증 정보가 다릅니다.
    """

    status_code = status.HTTP_400_BAD_REQUEST
    code = "M0009"


class ExpiredTokenException(AppException):
    """
    만료된 토큰입니다
    """

    status_code = status.HTTP_401_UNAUTHORIZED
    code = "M0000"


class TitleLengthExceededException(AppException):
    """
    쪽지 제목이 너무 깁니다.
    """

    status_code = status.HTTP_400_BAD_REQUEST
    code = "L0019"


class ContentLengthExceededException(AppException):
    """
    쪽지 내용이 너무 깁니다.
    """

    status_code = status.HTTP_400_BAD_REQUEST
    code = "L0020"


class HintLengthExceededException(AppException):
    """
    보물 쪽지 힌트가 너무 깁니다.
    """

    status_code = status.HTTP_400_BAD_REQUEST
    code = "L0021"


class SelfRecipientException(AppException):
    """
    쪽지 수신자 중에 자기 자신이 존재합니다.
    """

    status_code = status.HTTP_400_BAD_REQUEST
    code = "L0022"


class UnauthorizedGroupAccessException(AppException):
    """
    그룹에 대한 접근 권한이 없습니다.
    """

    status_code = status.HTTP_401_UNAUTHORIZED
    code = "G0003"


class TreasureSearchRangeTooBroadException(AppException):
    """
    지구상의 두 점의 지구 중심에 대한 각도가 180도에 가까우면 발생. 거의 발생할 일이 없음.
    """

    status_code = status.HTTP_400_BAD_REQUEST
    code = "L0023"


class GroupIncludesOwnerException(AppException):
    """
    그룹 멤버 안에 그룹 소유자가 존재하는 상태로 생성하려 하고 있습니다.
    """

    status_code = status.HTTP_400_BAD_REQUEST
    code = "G0003"


class NSFWImageDetectedException(AppException):
    """
    이미지가 유해한 이미지로 판단됩니다.
    """

    status_code = status.HTTP_400_BAD_REQUEST
    code = "L0026"
