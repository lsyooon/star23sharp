import datetime
from zoneinfo import ZoneInfo

LOCAL_TIMEZONE = "Asia/Seoul"

LocalTimeZone = ZoneInfo(LOCAL_TIMEZONE)


def illegal_adjust_time_to_gmt(
    incorrect_local_time, local_timezone=LocalTimeZone
) -> datetime.datetime:
    """
    Client에서 자신의 로컬 time을 timestamp로 착각하고 보내는 경우, time을 shift 하기 위한 함수
    """

    return incorrect_local_time - local_timezone.utcoffset(incorrect_local_time)
