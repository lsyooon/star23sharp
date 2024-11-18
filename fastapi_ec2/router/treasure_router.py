import datetime
import logging
from typing import List, Optional, Tuple

import numpy as np
from dto.member_dto import MemberDTO
from dto.treasure_dto import (
    ResponseTreasureDTO_Any,
    ResponseTreasureDTO_Opened,
    ResponseTreasureDTO_Own,
    ResponseTreasureDTO_Undiscovered,
    TreasureDTO_Opened,
    TreasureDTO_Own,
    TreasureDTO_Undiscovered,
)
from entity.member import Member
from entity.message import Message, ReceiverTypes, VarcharLimit
from entity.message_box import MessageDirections
from fastapi import APIRouter, BackgroundTasks, Depends, File, Form, Query, UploadFile
from response.exceptions import (
    AmbiguousTargetException,
    ContentLengthExceededException,
    GPUProxyServerException,
    GroupIncludesOwnerException,
    GroupNotFoundException,
    HintLengthExceededException,
    InvalidInputException,
    InvalidPixelTargetException,
    NSFWImageDetectedException,
    SelfRecipientException,
    TitleLengthExceededException,
    TreasureNotFoundException,
    TreasureSearchRangeTooBroadException,
    UnauthorizedTreasureAccessException,
)
from service.group_service import (
    assert_check_group_ownership,
    find_group_by_id,
    insert_new_group,
)
from service.image_service import (
    PIXELIZE_DEFAULT_KERNEL,
    PIXELIZE_DEFAULT_PIXEL_SIZE,
    check_nsfw_service,
    get_embedding_of_two_images,
    get_embedding_service,
    pixelize_image_service,
)
from service.member_service import (
    assert_member_by_id,
    find_members_by_nickname_no_validation,
)
from service.message_box_service import (
    delete_message_trace,
    get_nonpublic_treasure_messagebox_if_authorizable,
    get_treasure_message_if_accesible,
    insert_multiple_new_recieved_message_boxs_to_a_message,
    insert_new_message_box,
)
from service.message_service import (
    authorize_treasure_message,
    find_distinct_multiple_treasures_by_id,
    find_near_treasures,
    find_treasure_by_id,
    insert_new_treasure_message,
)
from service.notification_service import (
    treasure_hidden_notification_to_receivers,
    treasure_revealed_notification_to_sender,
)
from sqlalchemy import select
from sqlalchemy.orm import Session
from utils.connection_pool import get_db
from utils.datetime_util import illegal_adjust_time_to_gmt
from utils.distance_util import (
    RADIUS_EARTH,
    assert_lat_lng_validity,
    convert_lat_lng_to_xyz,
    get_cosine_distance,
    get_distance_from_radian,
)
from utils.resource import (
    construct_s3_link,
    delete_image_from_storage,
    download_file,
    generate_uuid_filename,
    save_image_to_storage,
)
from utils.security import get_current_member

logger = logging.getLogger(__name__)

# 코사인 거리 임계값
# THRESHOLD_COSINE_DISTANCE_LOW = (
#     0.55  # 코사인 거리가 이 값 미만이면 지나치게 유사해서 저장 불가
# )
THRESHOLD_COSINE_DISTANCE_HIGH = 0.8491  # 코사인 거리가 이 값 이상이면 다른 장소로 판단

# 반경 범위 임계값
THRESHOLD_LINEAR_DISTANCE = 20  # meter

treasure_router = APIRouter()

INSERT_DESCRIPTION = f"""
새로운 보물 메시지를 생성하고 저장합니다.

첫 번째 힌트 이미지와 두 번째 힌트 이미지를 업로드하고, 이 두 이미지의 임베딩을 계산하여 보물 메시지를 생성합니다.

- 픽셀 힌트 이미지는 선택 사항이며, 제공되지 않을 경우 지정된 힌트 이미지를 픽셀화하여 생성합니다.
- **수신 대상은 그룹 ID 또는 수신자 목록으로 지정할 수 있으며, 둘 다 제공되지 않을 경우 Public 메시지로 등록됩니다.**
- 메시지 제목, 내용, 첨부 이미지, 텍스트 힌트를 포함할 수 있습니다.

## 매개변수
- receiverType (int, Optional): 수신자 타입. 0 : 개인, 1:그룹 지정 x 단체, 2: 그룹 지정 O 단체, 3 :불특정 다수. 지정하지 않으면 입력값에서 추론합니다.
- hint_image_first (UploadFile): 첫 번째 힌트 이미지
- hint_image_second (UploadFile): 두 번째 힌트 이미지
- dot_hint_image (UploadFile, Optional): 픽셀 힌트 이미지. 제공되지 않을 경우 dot_target에 따라 지정된 힌트 이미지를 픽셀화합니다.
- dot_target (int, Optional): dot_hint_image를 제공하지 않을 때 픽셀화할 힌트 이미지의 번호. 1(첫 번째), 2(두 번째). 기본값은 1.
- kernel_size (int, Optional): 픽셀화 시 사용할 커널 크기. 미제공 시 기본값 {PIXELIZE_DEFAULT_KERNEL} 사용.
- pixel_size (int, Optional): 픽셀화 시 사용할 픽셀 크기. 미제공 시 기본값 {PIXELIZE_DEFAULT_PIXEL_SIZE} 사용.
- title (str): 메시지 제목. `{VarcharLimit.TITLE.value}` 자 이내
- content (str): 메시지 내용. `{VarcharLimit.CONTENT.value}` 자 이내
- contentImage (UploadFile, Optional): 메시지 첨부 이미지
- hint (str, Optional): 텍스트 힌트. `{VarcharLimit.HINT.value}` 자 이내
- groupId (int, Optional): 그룹 ID. 특정 그룹에게 보낼 때 사용
- receivers (List[str], Optional): 수신자들의 멤버 닉네임 목록
- lat (float): 위도
- lng (float): 경도
- createdAt (datetime, Optional): 메시지 송신 시각. 미제공 시 현재 시각 사용.

## 반환값
- ResponseTreasureDTO_Own: 생성된 보물 메시지 정보
"""

INSPECT_DESCRIPTION = """
제공받은 보물 메세지들의 ID 에 대해 최신화된 상세 정보를 제공합니다
## 매개변수:
- ids (List[int]): 상세 조회하고 싶은 보물 메세지들의 고유 id
## 반환값
- ResponseTreasureDTO_Any
    - 제공받은 ID 에 대해서 **정보를 가져올 수 있는** 보물 메세지들의 정보만 표시합니다.
    - 각 보물 메세지의 상세한 정보는 사용자의 접근 권한에 따라 다릅니다.
        - **자신이 보물 메세지의 작성자인 경우**: 모든 정보를 얻습니다.
        - **자신이 열람한 보물 메세지인 경우**: 열람 시의 정보를 얻습니다.
        - **자신이 열람 시도 가능한 보물 메세지인 경우**: 제목과 좌표, 힌트 이미지 정도만 얻습니다.
"""

FIND_DESCRIPTION = """
좌표 두 개를 제공하면 두 지점을 지름으로 가지는 원 안의 접근 가능한 보물 메세지들을 제공합니다.
## 매개변수:
- lat_1 (float): 첫 번째 좌표 위도.
- lng_1 (float): 첫 번째 좌표 경도.
- lat_2 (float): 두 번째 좌표 위도.
- lng_2 (float): 두 번째 좌표 경도.
- include_opened (bool): 기본값 `false`
    - get_received 가 `true` 일 때는(즉, 자신이 접근 가능한 보물 쪽지 조회) **자신이** 이미 열람한 보물 메세지를 포함할지의 여부
    - get_received `false` 일 때는(즉, 자신이 작성한 보물 쪽지 조회) **누군가** 열람한 보물 메세지를 포함할 지의 여부
- get_received (bool): **true이면 자신이 접근 가능한 보물 메세지만, false이면 자신이 등록한 보물 메세지만 가져옵니다.** 기본값 `false`.
### 아래 세 매개변수가 모두 false 이면 빈 결과를 제공합니다.
- include_public: 퍼블릭 보물 메세지를 포함할지의 여부. 기본값 `false`
- include_group: 그룹 또는 다수 대상으로 등록된 보물 메세지를 포함할지의 여부. 기본값 `false`
- include_private: 개인을 대상으로 등록된 보물 메세지를 포함할지의 여부. 기본값 `false`
## 반환값
- ResponseTreasureDTO_Undiscovered
    - 주어진 두 좌표의 중심점에서 가까운 순서대로 정렬되어 제공됩니다.
"""

AUTHORIZE_DESCRIPTION = f"""
보물 메시지의 열람 인증을 처리합니다.
사용자가 업로드한 이미지와 위치 정보를 기반으로 보물 메시지에 대한 인증을 수행합니다.
## 인증 조건
인증 성공을 위해 사용자는 다음과 같은 조건을 만족해야 합니다.
1. 해당 보물 메세지에 대한 접근 권한이 있어야 합니다.
2. 해당 보물 메세지에 대해 `{THRESHOLD_LINEAR_DISTANCE}` 미터 안에 있어야 합니다.
3. 업로드한 이미지 파일의 AI 임베딩 값과 열람하고자 하는 메세지의 코사인 거리가 `{THRESHOLD_COSINE_DISTANCE_HIGH}` 이내여야 합니다.

## 인증 성공 시
1. 해당 보물 메세지의 발견자는 해당 사용자가 됩니다
2. 해당 사용사의 수신함에서는 읽음 처리됩니다.
3. 다른 모든 사용자들은 해당 메세지에 대한 접근 권한을 잃습니다.

## 기타
- 자기 자신이 발송한 public이 아닌 보물 쪽지는 인증할 수 없습니다.
    - **반대로 말하면, public 보물 쪽지는 자기 자신이 인증할 수 있습니다.**
- 이미 자신이 인증한 적이 있는 보물 쪽지도 인증할 수 없습니다.

## 매개변수:
- file (UploadFile): 테스트할 이미지 파일.
- id (int): 보물 메시지의 Id.
- lat (float): 현재 위도.
- lng (float): 현재 경도.

## 반환값:
- ResponseTreasureDTO_Opened: 인증 결과와 보물 메시지 정보.

### 인증 결과에 따라 message 필드는 다음 값을 가질 수 있습니다:
- "success": 인증에 성공한 경우.
- "member_too_far": 사용자의 위치가 보물 위치와 너무 먼 경우.
- "image_not_similar": 업로드한 이미지가 보물 이미지와 유사하지 않은 경우.
- "already_found" : 인증에 성공했지만, 이미 다른 유저가 먼저 인증에 성공한 경우.
"""


@treasure_router.post(
    "/insert",
    response_model=ResponseTreasureDTO_Own,
    summary="새 보물 메시지 등록",
    description=INSERT_DESCRIPTION,
)
async def insert_new_treasure(
    background_tasks: BackgroundTasks,
    hint_image_first: UploadFile = File(..., description="첫 번째 힌트 이미지"),
    hint_image_second: UploadFile = File(..., description="두 번째 힌트 이미지"),
    dot_hint_image: Optional[UploadFile] = File(
        None,
        description="픽셀 힌트 이미지. 제공하지 않아도 다른 Form Data Field 를 통해 힌트 이미지를 픽셀화할 수 있습니다.",
    ),
    dot_target: Optional[int] = Form(
        None,
        description="dot_hint_image를 제공하지 않을 때 픽셀화할 힌트 이미지의 번호. 1(첫 번째) 또는 2(두 번째). 미제공 시 첫 번째 이미지 사용.",
    ),
    kernel_size: Optional[int] = Form(
        None,
        description=f"dot_hint_image를 제공하지 않을 때 파라미터. 미제공 시 기본값({PIXELIZE_DEFAULT_KERNEL}) 사용. 상세 내용은 도트화 API 참고.",
    ),
    pixel_size: Optional[int] = Form(
        None,
        description=f"dot_hint_image를 제공하지 않을 때 파라미터. 미제공 시 기본값({PIXELIZE_DEFAULT_PIXEL_SIZE}) 사용. 상세 내용은 도트화 API 참고.",
    ),
    title: str = Form(..., description="메시지 제목"),
    content: str = Form(..., description="메시지 내용"),
    contentImage: Optional[UploadFile] = File(None, description="메시지 첨부 이미지"),
    hint: Optional[str] = Form(None, description="텍스트 힌트"),
    receiverType: Optional[int] = Form(
        None,
        description="수신자 타입. 0 : 개인, 1:그룹 지정 x 단체, 2: 그룹 지정 O 단체, 3 :불특정 다수. 지정하지 않으면 입력값에서 추론합니다.",
    ),
    groupId: Optional[int] = Form(
        None, description="그룹을 지정해서 보낼 경우 해당 그룹 ID"
    ),
    receivers: Optional[List[str]] = Form(
        None, description="수신자들의 멤버 닉네임 목록."
    ),
    lat: float = Form(..., description="위도"),
    lng: float = Form(..., description="경도"),
    createdAt: Optional[datetime.datetime] = Form(
        None, description="메시지 송신 시각. 제공되지 않으면 현재 시각으로 저장됩니다."
    ),
    current_member_info: Tuple[MemberDTO, str] = Depends(get_current_member),
    db: Session = Depends(get_db),
):
    hint_image_first_name_gen = None
    hint_image_second_name_gen = None
    dot_hint_image_name_gen = None
    content_image_name_gen = None
    try:
        # Form parameter translation. camcelCase -> snake_case
        receiver_type = receiverType
        group_id = groupId
        created_at = createdAt
        content_image = contentImage

        # 송신 시각 처리
        if created_at is None:
            created_at = datetime.datetime.now()
        # created_at = illegal_adjust_time_to_gmt(created_at)

        # 입력값 검증
        if len(title) > VarcharLimit.TITLE.value:
            raise TitleLengthExceededException()
        if content and len(content) > VarcharLimit.CONTENT.value:
            raise ContentLengthExceededException()
        if hint and len(hint) > VarcharLimit.HINT.value:
            raise HintLengthExceededException()
        assert_lat_lng_validity(lat, lng)

        # 수신 Type에 따른 Sanitize
        if receiver_type is not None:
            if receiver_type == ReceiverTypes.INDIVIDUAL.value:
                if receivers is None or len(receivers) != 1:
                    raise InvalidInputException("수신 대상이 없거나 한 명이 아닙니다.")
                group_id = None
            elif receiver_type == ReceiverTypes.GROUP_UNCONSTRUCTED.value:
                if receivers is None or len(receivers) < 2:
                    raise InvalidInputException("수신 대상이 없거나 두 명 미만입니다.")
                group_id = None
            elif receiver_type == ReceiverTypes.GROUP_CONSTRUCTED.value:
                if group_id is None:
                    raise InvalidInputException(
                        "메세지를 받을 그룹을 지정하지 않았습니다."
                    )
                receivers = None
            elif receiver_type == ReceiverTypes.PUBLIC.value:
                receivers = None
                group_id = None
            else:
                raise InvalidInputException(
                    f"receiver_type이 들어왔지만 유효한 값이 아닙니다! 들어온 값 : {receiver_type}"
                )

        # 멤버 존재 검증
        current_member = assert_member_by_id(current_member_info[0].id, db)

        # 수신 대상 파악
        receiving_members: List[Member] = []
        if receivers is not None and group_id is not None:
            raise AmbiguousTargetException()
        elif receivers is not None:
            receiving_members = find_members_by_nickname_no_validation(receivers, db)
            if len(receiving_members) == 1:
                if receiving_members[0].id is current_member.id:
                    raise SelfRecipientException()
                result_receiver_type = ReceiverTypes.INDIVIDUAL.value
                receiving_group = None
            else:
                result_receiver_type = ReceiverTypes.GROUP_UNCONSTRUCTED.value
                # 새로운 그룹 생성
                try:
                    receiving_group = insert_new_group(
                        None,
                        current_member,
                        False,
                        False,
                        receiving_members,
                        created_at,
                        db,
                    )
                except GroupIncludesOwnerException:
                    raise SelfRecipientException()
        elif group_id is not None:
            result_receiver_type = ReceiverTypes.GROUP_CONSTRUCTED.value
            receiving_group = find_group_by_id(group_id, db)
            if receiving_group is None:
                raise GroupNotFoundException()
        else:
            result_receiver_type = ReceiverTypes.PUBLIC.value
            receiving_group = None

        # 수신자 목록 생성
        result_receiving_members: List[Member] = []
        if receiving_group:  # 여러명에게 발신
            assert_check_group_ownership(receiving_group, current_member, db)
            result_receiving_members = [
                group_member.member for group_member in receiving_group.group_members
            ]
        elif result_receiver_type is ReceiverTypes.INDIVIDUAL.value:  # 개인에게 발신
            result_receiving_members = receiving_members

        # 이미지 내용 읽기
        hint_image_first_file = await download_file(hint_image_first)
        hint_image_second_file = await download_file(hint_image_second)

        # 픽셀화 힌트 이미지 읽기
        if dot_hint_image:
            dot_hint_image_file = await download_file(dot_hint_image)
        else:
            # dot_hint_image가 제공되지 않은 경우, 픽셀화
            if dot_target is None or dot_target == 1:
                _to_dot = hint_image_first_file
            elif dot_target == 2:
                _to_dot = hint_image_second_file
            else:
                raise InvalidPixelTargetException()
            dot_hint_image_file = await pixelize_image_service(
                _to_dot,
                PIXELIZE_DEFAULT_PIXEL_SIZE if kernel_size is None else kernel_size,
                PIXELIZE_DEFAULT_PIXEL_SIZE if pixel_size is None else pixel_size,
            )

        # 메시지 첨부 이미지 읽기
        content_image_file = (
            await download_file(content_image) if content_image is not None else None
        )

        # 이미지 이름 생성
        hint_image_first_name = generate_uuid_filename(hint_image_first_file)
        hint_image_second_name = generate_uuid_filename(hint_image_second_file)
        dot_hint_image_name = (
            generate_uuid_filename(dot_hint_image_file)
            if dot_hint_image_file is not None
            else None
        )
        content_image_name = (
            generate_uuid_filename(content_image_file)
            if content_image_file is not None
            else None
        )

        # 이미지 URL 미리 생성
        hint_image_first_url = construct_s3_link(hint_image_first_name)
        hint_image_second_url = construct_s3_link(hint_image_second_name)
        dot_hint_image_url = (
            construct_s3_link(dot_hint_image_name)
            if dot_hint_image_name is not None
            else None
        )
        content_image_url = (
            construct_s3_link(content_image_name)
            if content_image_name is not None
            else None
        )

        # 힌트 이미지 임베딩 생성
        embeddings = await get_embedding_of_two_images(
            hint_image_first_file, hint_image_second_file
        )

        # 평균 벡터 계산
        embeddings_array = np.array(embeddings)
        result_vector = (embeddings_array[0] + embeddings_array[1]) / 2
        result_vector = result_vector.tolist()

        # 새 보물 메시지 생성 및 저장
        new_message = insert_new_treasure_message(
            sender=current_member,
            receiver_type=result_receiver_type,
            receivers=result_receiving_members,
            hint_image_first=hint_image_first_url,
            hint_image_second=hint_image_second_url,
            dot_hint_image=dot_hint_image_url,
            title=title,
            content=content,
            hint=hint,
            lat=lat,
            lng=lng,
            image=content_image_url,
            created_at=created_at,
            vector=result_vector,
            group=receiving_group,
            session=db,
        )

        # 발송함에 추가
        insert_new_message_box(
            new_message,
            current_member,
            MessageDirections.SENT.value,
            created_at,
            db,
        )

        # 수신함에 추가
        insert_multiple_new_recieved_message_boxs_to_a_message(
            new_message, result_receiving_members, created_at, db
        )
        result_model = TreasureDTO_Own.get_dto(new_message)

        # 파일 저장
        hint_image_first_name_gen = save_image_to_storage(
            hint_image_first_file, hint_image_first_name
        )
        hint_image_second_name_gen = save_image_to_storage(
            hint_image_second_file, hint_image_second_name
        )
        dot_hint_image_name_gen = (
            save_image_to_storage(dot_hint_image_file, dot_hint_image_name)
            if dot_hint_image_file is not None
            else None
        )
        # Content Image의 경우 nsfw check 도 해야함
        if content_image_file is not None:
            if not await check_nsfw_service(content_image_file):
                raise NSFWImageDetectedException("첨부 이미지가 유해한 이미지입니다!!")
            content_image_name_gen = save_image_to_storage(
                content_image_file, content_image_name
            )

        # transaction end 전에 알림용 데이터 저장
        result_message_id = new_message.id
        result_receivers_int = (
            [member.id for member in result_receiving_members]
            if len(result_receiving_members) > 0
            else None
        )

        # 커밋!
        db.commit()

        # 수신자에게 알림 보내기
        if result_receivers_int is not None:
            background_tasks.add_task(
                treasure_hidden_notification_to_receivers,
                messageId=result_message_id,
                receivers=result_receivers_int,
                token=current_member_info[1],
            )
        return ResponseTreasureDTO_Own(
            code="200", message="작성 완료.", data=result_model
        )
    except Exception:
        db.rollback()
        if hint_image_first_name_gen is not None:
            delete_image_from_storage(hint_image_first_name)
        if hint_image_second_name_gen is not None:
            delete_image_from_storage(hint_image_second_name)
        if dot_hint_image_name_gen is not None:
            delete_image_from_storage(dot_hint_image_name)
        if content_image_name_gen is not None:
            delete_image_from_storage(content_image_name)
        raise


@treasure_router.get(
    "/inspect",
    response_model=ResponseTreasureDTO_Any,
    summary="보물 메세지 상세조회",
    description=INSPECT_DESCRIPTION,
)
async def inspect_treasures(
    ids: List[int] = Query(
        ..., description="조회하고자 하는 보물 메세지들의 고유 id들"
    ),
    current_member_info: Tuple[MemberDTO, str] = Depends(get_current_member),
    db: Session = Depends(get_db),
):
    member_orm = assert_member_by_id(current_member_info[0].id, db)
    treasure_orms: List[Message] = find_distinct_multiple_treasures_by_id(ids, db)
    result_dtos = []
    for treasure in treasure_orms:
        if treasure.sender_id is member_orm.id:  # 내가 이 메세지를 보낸 사람
            result_dtos.append(TreasureDTO_Own.get_dto(treasure))
        elif get_treasure_message_if_accesible(
            member_orm, treasure, db
        ):  # 열람하거나 접근 가능한 메세지임(퍼블릭일 수도 있음!)
            if treasure.is_found:
                result_dtos.append(TreasureDTO_Opened.get_dto(treasure))
            else:
                result_dtos.append(TreasureDTO_Undiscovered.get_dto(treasure))
        elif (
            treasure.receiver_type is ReceiverTypes.PUBLIC.value
            and not treasure.is_found
        ):  # 아무도 못 찾은 public 메세지면 접근 가능
            result_dtos.append(TreasureDTO_Undiscovered.get_dto(treasure))

    return ResponseTreasureDTO_Any(
        code="200", message="조회 완료.", data={"treasures": result_dtos}
    )


@treasure_router.get(
    "/near",
    response_model=ResponseTreasureDTO_Undiscovered,
    summary="주변 보물 메세지 찾기",
    description=FIND_DESCRIPTION,
)
async def find_near_treasures_around_me(
    lat_1: float = Query(..., description="첫 번째 좌표의 위도"),
    lng_1: float = Query(..., description="첫 번째 좌표의 경도"),
    lat_2: float = Query(..., description="두 번째 좌표의 위도"),
    lng_2: float = Query(..., description="두 번째 좌표의 경도"),
    include_opened: bool = Query(
        False,
        description="설명 참조",
    ),
    get_received: bool = Query(
        False,
        description="true 이면 자신이 접근 가능한 보물 메세지를, false 이면 자신이 등록한 보물 메세지를 가져옵니다.",
    ),
    include_public: bool = Query(False, description="퍼블릭 메세지를 가져올지의 여부."),
    include_group: bool = Query(
        False, description="그룹 또는 여러 명에게 보낸 메세지를 가져올지의 여부."
    ),
    include_private: bool = Query(
        False, description="1대1 보물 메세지를 가져올지의 여부."
    ),
    current_member_info: Tuple[MemberDTO, str] = Depends(get_current_member),
    db: Session = Depends(get_db),
):
    member_orm = assert_member_by_id(current_member_info[0].id, db)
    assert_lat_lng_validity(lat_1, lng_1)
    assert_lat_lng_validity(lat_2, lng_2)

    xyz_1 = np.array(convert_lat_lng_to_xyz(lat_1, lng_1))
    xyz_2 = np.array(convert_lat_lng_to_xyz(lat_2, lng_2))
    center_xyz_short = (xyz_1 + xyz_2) / 2
    center_norm_length = np.linalg.norm(center_xyz_short)
    if center_norm_length < 1:  # 거의 일어나지 않음
        raise TreasureSearchRangeTooBroadException()
    center_xyz = RADIUS_EARTH * (center_xyz_short / np.linalg.norm(center_xyz_short))
    radius = float(
        get_distance_from_radian(
            np.acos(1 - get_cosine_distance(xyz_1, center_xyz, dtype=np.float128))
        )
    )
    query_result: List[Message] = []
    receiver_types: List[int] = []
    if include_public:
        receiver_types.append(ReceiverTypes.PUBLIC.value)
    if include_group:
        receiver_types.append(ReceiverTypes.GROUP_CONSTRUCTED.value)
        receiver_types.append(ReceiverTypes.GROUP_UNCONSTRUCTED.value)
    if include_private:
        receiver_types.append(ReceiverTypes.INDIVIDUAL.value)
    if len(receiver_types) > 0:
        query_result = find_near_treasures(
            member_orm,
            center_xyz,
            radius,
            include_opened,
            receiver_types,
            get_received,
            db,
        )
    result_dtos = [
        TreasureDTO_Undiscovered.get_dto(treasure) for treasure in query_result
    ]

    return ResponseTreasureDTO_Undiscovered(
        code="200", message="조회 완료.", data={"treasures": result_dtos}
    )


@treasure_router.post(
    "/authorize",
    response_model=ResponseTreasureDTO_Opened,
    summary="보물 메세지 검증",
    description=AUTHORIZE_DESCRIPTION,
)
async def authorize_treasure(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(..., description="테스트할 이미지"),
    id: int = Form(..., description="보물 메시지의 ID"),
    lat: float = Form(..., description="현재 위도"),
    lng: float = Form(..., description="현재 경도"),
    current_member_info: Tuple[MemberDTO, str] = Depends(get_current_member),
    db: Session = Depends(get_db),
):
    # 인증 시도 시각
    created_at = datetime.datetime.now()

    # 시도자 검증
    current_member = assert_member_by_id(current_member_info[0].id, db)

    # 좌표 입력값 검증
    assert_lat_lng_validity(lat, lng)

    # 메세지 검증
    target_treasure = find_treasure_by_id(id, db)
    if target_treasure is None:
        raise TreasureNotFoundException()

    is_public = (
        target_treasure.receiver_type is ReceiverTypes.PUBLIC.value
    )  # public일 경우에는 자기 자신이 자기 메세지 검증 가능.
    if not is_public:
        box_row = get_nonpublic_treasure_messagebox_if_authorizable(
            current_member, target_treasure, db
        )
        if box_row is None:
            raise UnauthorizedTreasureAccessException()

    # 임베딩 얻음
    response = await get_embedding_service(file)
    response_json = response.json()
    embedding: List[float] = response_json.get("embedding")
    if not embedding:
        logger.error("임베딩 서버에서 임베딩을 반환하지 않았습니다.")
        raise GPUProxyServerException()

    db.flush()

    # 보물 메시지 인증
    auth_result = authorize_treasure_message(
        target_treasure,
        embedding,
        lat,
        lng,
        cos_distance_threshold=THRESHOLD_COSINE_DISTANCE_HIGH,
        linear_distance_threshold=THRESHOLD_LINEAR_DISTANCE,
    )

    treasure_result = None

    if auth_result[0]:
        # Lock과 함께 Message 객체를 가져온다.
        locked_treasure_stmt = select(Message).where(Message.id == id).with_for_update()
        locked_treasure = db.execute(locked_treasure_stmt).scalar_one()

        # Ensure `locked_treasure` is used for updates to maintain locking
        if locked_treasure.is_found is True:  # 메세지가 이미 발견됨
            result_message = "already_found"
        else:
            locked_treasure.is_found = True  # 메세지 발견 처리
            locked_treasure.receiver = [
                current_member.id
            ]  # 수신자 변경(초기 수신자는 Group에 남아있으니 정보 유실은 없음)
            treasure_result = TreasureDTO_Opened.get_dto(locked_treasure)
            if is_public:
                box_row = insert_new_message_box(
                    locked_treasure,
                    current_member,
                    MessageDirections.RECEIVED.value,
                    created_at=created_at,
                    session=db,
                )
            box_row.state = True  # 열람 처리
            db.flush()  # 세션 동기화
            delete_message_trace(locked_treasure, db)
            db.commit()
            # 알림 처리
            background_tasks.add_task(
                treasure_revealed_notification_to_sender,
                messageId=id,
                token=current_member_info[1],
            )
            result_message = "success"
    else:
        if auth_result[1] is None:
            result_message = "member_too_far"
        else:
            result_message = "image_not_similar"
    return ResponseTreasureDTO_Opened(
        code="200", message=result_message, data=treasure_result
    )
