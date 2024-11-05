import datetime
from typing import List, Optional, Union

from dto.member_dto import MemberDTO
from entity.member import Member
from entity.message import Message
from entity.message_box import MESSAGE_DIRECTION_RECEIVED, MessageBox
from sqlalchemy import delete, select
from sqlalchemy.orm.session import Session as Session_Object

from .member_service import find_member_by_id
from .message_service import is_message_public


def insert_new_message_box(
    message: Message,
    member: Member,
    message_direction: int,
    created_at: datetime.datetime,
    session: Session_Object,
) -> MessageBox:
    new_message_box = MessageBox(
        message_id=message.id,
        member_id=member.id,
        message_direction=message_direction,
        created_at=created_at,
    )
    session.add(new_message_box)
    session.flush()
    return new_message_box


def insert_multiple_new_recieved_message_boxs_to_a_message(
    message: Message,
    members: List[Member],
    created_at: datetime.datetime,
    session: Session_Object,
) -> List[MessageBox]:
    if members is None or len(members) == 0:
        return []
    boxrows = [
        MessageBox(
            message_id=message.id,
            member_id=a_member.id,
            message_direction=MESSAGE_DIRECTION_RECEIVED,
            created_at=created_at,
        )
        for a_member in members
    ]
    session.add_all(boxrows)
    session.flush()
    return boxrows


def get_authorizable_nonpublic_treasure_message(
    member: Union[MemberDTO, Member], treasure_message: Message, session: Session_Object
) -> Optional[MessageBox]:
    if is_message_public(treasure_message):
        raise ValueError(
            "get_authorizable_treasure_message: Public 보물 메세지에 대해 인증 가능한 MessageBox 개체를 얻어오려 시도하고 있음!!!"
        )
    if isinstance(member, MemberDTO):
        orm_member = find_member_by_id(member.id, session)
    else:
        orm_member = member

    stmt = (
        select(MessageBox)
        .where(MessageBox.member_id == orm_member.id)
        .where(MessageBox.message_id == treasure_message.id)
        .where(MessageBox.message_direction == MESSAGE_DIRECTION_RECEIVED)
        .where(MessageBox.state.is_(False))
    )
    return session.scalar(stmt)


def delete_message_trace(treasure_message: Message, session: Session_Object):
    """
    발견된 보물 메세지에 대해 발견자를 제외하고는 모두 수신함에서 삭제함.
    """
    if not treasure_message.is_found:
        raise ValueError(
            "delete_message_trace: 발견되지 않은 보물 메세지를 보관함에서 삭제하려 하고 있음!!!"
        )
    stmt = (
        delete(MessageBox)
        .where(MessageBox.message_id == treasure_message.id)
        .where(MessageBox.state.is_(False))  # 읽지 못함
        .where(MessageBox.message_direction == MESSAGE_DIRECTION_RECEIVED)
    )
    session.execute(stmt)
    session.flush()
