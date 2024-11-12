import datetime
import logging
from typing import List, Optional, Tuple

import numpy as np
from entity.group import MemberGroup
from entity.member import Member
from entity.message import Message, ReceiverTypes
from entity.message_box import MessageBox, MessageDirections
from sqlalchemy import and_, or_, select
from sqlalchemy.orm.session import Session as Session_Object
from utils.distance_util import (
    convert_lat_lng_to_xyz,
    get_cosine_distance,
    get_degree_from_distance,
    get_distance_from_degree,
    get_l2_distance_from_arc_distance,
)

logger = logging.getLogger(__name__)


def insert_new_treasure_message(
    sender: Member,
    receiver_type: int,
    receivers: Optional[List[Member]],
    hint_image_first: str,
    hint_image_second: str,
    dot_hint_image: str,
    title: str,
    content: Optional[str],
    hint: Optional[str],
    lat: float,
    lng: float,
    image: Optional[str],
    created_at: datetime.datetime,
    vector: List[float],
    group: Optional[MemberGroup],
    session: Session_Object,
) -> Message:
    new_msg = Message(
        sender_id=sender.id,
        receiver_type=receiver_type,
        receiver=(
            [member.id for member in receivers]
            if receivers and len(receivers) > 0
            else None
        ),
        hint_image_first=hint_image_first,
        hint_image_second=hint_image_second,
        dot_hint_image=dot_hint_image,
        title=title,
        content=content,
        hint=hint,
        lat=lat,
        lng=lng,
        coordinate=convert_lat_lng_to_xyz(lat, lng),
        is_treasure=True,
        created_at=created_at,
        image=image,
        vector=vector,
        group_id=group.id if group is not None else None,
    )

    session.add(new_msg)
    session.flush()
    return new_msg


def find_treasure_by_id(treasure_id: int, session: Session_Object) -> Optional[Message]:
    """
    Message ID로 보물 메시지를 조회합니다.

    Args:
        treasure_id (int): Message의 ID.
        session (Session): 데이터베이스 세션 객체.

    Returns:
        Optional[Message]: 조회된 Message 객체 또는 None.
    """
    stmt = (
        select(Message)
        .where(Message.id == treasure_id)
        .where(Message.is_treasure.is_(True))
    )
    return session.scalar(stmt)


def find_distinct_multiple_treasures_by_id(
    treasure_ids: List[int], session: Session_Object
) -> List[Message]:
    stmt = (
        select(Message)
        .where(Message.id.in_(treasure_ids))
        .where(Message.is_treasure.is_(True))
        .distinct()
    )
    return session.scalars(stmt).all()


def authorize_treasure_message(
    target_message: Message,
    vector: List[float],
    lat: float,
    lng: float,
    cos_distance_threshold: float = 0.8,  # 코사인 거리 임계값 (0 ~ 2)
    linear_distance_threshold: float = 20,  # 거리 임계값 (미터 단위)
) -> Tuple[bool, Optional[float]]:
    """
    보물 메시지의 인증을 수행.

    Args:
        target_message_id (int): 인증할 보물 메시지의 ID.
        vector (List[float]): 비교할 이미지의 벡터.
        coordinate (List[float]): 현재 위치 좌표 [위도, 경도].
        session (Session): 데이터베이스 세션 객체.
        cos_distance_threshold (float): 코사인 거리 임계값.
        linear_distance_threshold (float): 거리 임계값 (미터 단위).

    Returns:
        Tuple[bool, Optional[float]]: (인증 성공 여부, 코사인 거리 값). 거리 값이 없으면 인증 시도 위치가 너무 멂
    """

    # 거리 측정
    xyz_coord = convert_lat_lng_to_xyz(lat, lng)
    current_degree_between_points = float(
        (180 / np.pi)
        * np.arccos(
            1
            - get_cosine_distance(
                target_message.coordinate, xyz_coord, dtype=np.float128
            )
        )
    )
    threshold = get_degree_from_distance(linear_distance_threshold)
    logger.debug(
        f"authorize_treasure_message: 지구 위치상 각도 = {current_degree_between_points} 도, 거리 = {get_distance_from_degree(current_degree_between_points)}, 임계값 = {threshold}"
    )

    if current_degree_between_points >= threshold:
        return False, None

    cosine_distance = float(get_cosine_distance(target_message.vector, vector))
    logger.debug(f"authorize_treasure_message: 코사인 거리 = {cosine_distance}")

    if cosine_distance >= cos_distance_threshold:
        return False, cosine_distance

    return True, cosine_distance


def find_near_treasures(
    valid_member: Member,
    xyz: List[float] | np.ndarray,
    radius: float,
    include_opened: bool,
    receiver_types: List[int],
    search_received: bool,
    session: Session_Object,
):
    stmt = select(Message)
    stmt = stmt.where(Message.receiver_type.in_(receiver_types))

    if search_received:
        stmt = stmt.outerjoin(MessageBox, MessageBox.message_id == Message.id).where(
            or_(
                and_(
                    MessageBox.member_id
                    == valid_member.id,  # 자신에게 접근 권한이 있어야 함. non_public한 접근가능 메세지나, public한 내가 열람한 메세지를 가져온다.
                    MessageBox.message_direction == MessageDirections.RECEIVED.value,
                ),
                and_(  # 그게 아니면 public이면서 누군가 발견한 적이 없어야 함
                    Message.receiver_type == ReceiverTypes.PUBLIC.value,
                    Message.is_found.is_(False),
                ),
            )
        )
    else:
        stmt = stmt.where(Message.sender_id == valid_member.id)

    if not include_opened:  # 내가 찾은 보물 쪽지도 가져올지의 여부
        stmt = stmt.where(Message.is_found.is_(False))

    l2_distance_threshold = get_l2_distance_from_arc_distance(radius)
    stmt = (
        stmt.where(Message.is_treasure.is_(True))
        .filter(Message.coordinate.l2_distance(xyz) < l2_distance_threshold)
        .order_by(Message.coordinate.l2_distance(xyz))
    )
    return session.scalars(stmt).all()
