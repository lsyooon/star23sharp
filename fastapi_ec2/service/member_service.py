import logging
from typing import List, Optional

from entity.member import Member
from response.exceptions import MemberNotFoundException
from sqlalchemy.orm.session import Session as Session_Object

from .simple_find import find_by_attribute, find_distinct_multiple_by_attribute


def find_member_by_id(id: int, session: Session_Object) -> Optional[Member]:
    member = find_by_attribute(Member, Member.id, id, session=session)
    if is_member_valid(member, session):
        return member
    return None


def find_members_by_id_no_validation(
    id: List[int], session: Session_Object
) -> List[Member]:
    unique_ids = list(set(id))
    if len(unique_ids) != id:
        logging.warning("find_members_by_id_no_validation: 중복된 멤버 id가 존재함!!!")
    found_members = find_distinct_multiple_by_attribute(
        Member, Member.id, unique_ids, session
    )
    if len(found_members) == 0 or len(found_members) != len(unique_ids):
        raise MemberNotFoundException(
            "지정한 대상들 중 일부 또는 전체를 찾을 수 없습니다!"
        )
    return found_members


def find_members_by_nickname_no_validation(
    nicks: List[str], session: Session_Object
) -> List[Member]:
    unique_nicks = list(set(nicks))
    if len(nicks) != unique_nicks:
        logging.warning(
            "find_members_by_nickname_no_validation: 중복된 닉네임이 존재함!!!"
        )

    found_members = find_distinct_multiple_by_attribute(
        Member, Member.nickname, unique_nicks, session
    )
    if len(found_members) == 0 or len(found_members) != len(unique_nicks):
        raise MemberNotFoundException(
            "지정한 대상들 중 일부 또는 전체를 찾을 수 없습니다!"
        )
    return found_members


def find_member_by_member_name(
    member_name: str, session: Session_Object
) -> Optional[Member]:
    member = find_by_attribute(Member, Member.member_name, member_name, session=session)
    if is_member_valid(member, session):
        return member
    return None


def is_member_valid(member: Optional[Member], session: Session_Object) -> bool:
    if member is None:
        logging.warning(f"is_member_valid: cannot find Member: {id}")
        return False
    if member.state != 0:
        logging.warning(
            f"is_member_valid: The Member with id: {member.id} is not active Member"
        )
        return False
    return True


def assert_member_by_id(
    id: int,
    session: Session_Object,
    exception: Exception = MemberNotFoundException,
    message: str = None,
) -> Member:
    member = find_member_by_id(id, session)
    if member is None:
        raise exception(message)
    return member
