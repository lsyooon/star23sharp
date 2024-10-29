from typing import Optional
from sqlalchemy.orm.session import Session as Session_Object
from entity.member import Member

from .simple_find import find_by_attribute

def find_member_by_id(id: int, session: Session_Object) -> Optional[Member]:
    return find_by_attribute(Member, Member.id, id, session=session)

def find_member_by_member_name(member_name: str, session: Session_Object) -> Optional[Member]:
    return find_by_attribute(Member, Member.member_name, member_name, session=session)
