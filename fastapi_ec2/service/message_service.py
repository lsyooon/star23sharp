import logging
from typing import List, Optional, Tuple

from sqlalchemy import select
from sqlalchemy.orm import Session

from entity.message import Message
from .simple_find import find_by_attribute
from .member_service import find_member_by_id
from utils.distance_util import get_l2_distance, get_cosine_distance, get_degree_for_radius

logger = logging.getLogger(__name__)

def insert_new_treasure_message(
    sender_id: int,
    hint_image_first: str,
    hint_image_second: str,
    dot_hint_image: str,
    title: str,
    hint: str,
    coordinate: List[float],
    vector: List[float],
    session: Session,
) -> Optional[Message]:
    """
    디버깅용 함수.
    새로운 보물 메시지를 데이터베이스에 삽입합니다.

    Args:
        sender_id (int): 작성자 회원의 ID.
        hint_image_first (str): 첫 번째 힌트 이미지의 경로 또는 URL.
        hint_image_second (str): 두 번째 힌트 이미지의 경로 또는 URL.
        dot_hint_image (str): 도트 힌트 이미지의 경로 또는 URL.
        title (str): 메시지 제목.
        content (str): 메시지 내용.
        hint (str): 텍스트 힌트.
        coordinate (List[float]): 위치 좌표 [위도, 경도].
        vector (List[float]): 힌트 이미지의 벡터 표현.
        session (Session): 데이터베이스 세션 객체.

    Returns:
        Optional[Message]: 생성된 Message 객체 또는 None.
    """
    target_member = find_member_by_id(sender_id, session)
    if target_member is None:
        logger.warning(f"insert_new_treasure_message: 존재하지 않는 회원 ID = {sender_id}")
        return None

    new_msg = Message(
        sender_id=target_member.id,
        hint_image_first=hint_image_first,
        hint_image_second=hint_image_second,
        dot_hint_image=dot_hint_image,
        title=title,
        hint=hint,
        coordinate=coordinate,
        is_treasure=True,
        vector=vector,
    )

    session.add(new_msg)
    return new_msg

def find_treasure_by_id(treasure_id: int, session: Session) -> Optional[Message]:
    """
    Message ID로 보물 메시지를 조회합니다.

    Args:
        treasure_id (int): Message의 ID.
        session (Session): 데이터베이스 세션 객체.

    Returns:
        Optional[Message]: 조회된 Message 객체 또는 None.
    """
    return find_by_attribute(Message, Message.id, treasure_id, session)

def find_similar(vector: List[float], limit: int, session: Session) -> List[Message]:
    """
    주어진 벡터와 유사한 보물 메시지를 찾습니다.

    Args:
        vector (List[float]): 비교할 벡터.
        limit (int): 반환할 결과의 최대 개수.
        session (Session): 데이터베이스 세션 객체.

    Returns:
        List[Message]: 유사한 Message 객체들의 리스트.
    """
    stmt = (
        select(Message)
        .order_by(Message.vector.cosine_distance(vector))
        .limit(limit)
    )
    return session.scalars(stmt).all()

def authorize_treasure_message(
    target_message_id: int,
    vector: List[float],
    coordinate: List[float],
    session: Session,
    cos_distance_threshold: float = 0.8,  # 코사인 거리 임계값 (0 ~ 2)
    linear_distance_threshold: float = 20,  # 거리 임계값 (미터 단위)
) -> Tuple[bool, Optional[float]]:
    """
    보물 메시지의 인증을 수행합니다.

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
    target = find_treasure_by_id(target_message_id, session)
    if target is None:
        logger.warning(f"authorize_treasure_message: 존재하지 않는 보물 메시지 ID = {target_message_id}")
        raise ValueError(f"보물 메시지 ID {target_message_id}를 찾을 수 없습니다.")

    distance = get_l2_distance(target.coordinate, coordinate)
    threshold = get_degree_for_radius(linear_distance_threshold)
    logger.debug(f"authorize_treasure_message: 거리 = {distance}, 임계값 = {threshold}")

    if distance >= threshold:
        return False, None

    cosine_distance = get_cosine_distance(target.vector, vector)
    logger.debug(f"authorize_treasure_message: 코사인 거리 = {cosine_distance}")

    if cosine_distance >= cos_distance_threshold:
        return False, cosine_distance

    return True, cosine_distance
