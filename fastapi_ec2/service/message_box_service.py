import datetime
from typing import List

from sqlalchemy.orm.session import Session as Session_Object

from entity.member import Member
from entity.message import Message
from entity.message_box import MessageBox, MESSAGE_DIRECTION_RECIEVED

def insert_new_message_box(
    message: Message,
    member: Member,
    message_direction:int,
    created_at: datetime.datetime,
    session: Session_Object,
) -> MessageBox:
    new_message_box = MessageBox(
        message_id = message.id,
        member_id = member.id,
        message_direction = message_direction,
        created_at = created_at,
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
    if(members is None or len(members) == 0):
        return []
    boxrows = [
        MessageBox(
            message_id = message.id,
            member_id = a_member.id,
            message_direction = MESSAGE_DIRECTION_RECIEVED,
            created_at=created_at,
        )
        for a_member in members
    ]
    session.add_all(boxrows)
    session.flush()
    return boxrows