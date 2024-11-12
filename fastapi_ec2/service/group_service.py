import datetime
import logging
from typing import List, Optional

from entity.group import GroupMember, MemberGroup
from entity.member import Member
from response.exceptions import (
    GroupIncludesOwnerException,
    InvalidGroupMembersException,
    UnauthorizedGroupAccessException,
)
from sqlalchemy.orm.session import Session as Session_Object

from .member_service import is_member_valid
from .simple_find import find_by_attribute


def find_group_by_id(id: int, session: Session_Object) -> Optional[MemberGroup]:
    return find_by_attribute(MemberGroup, MemberGroup.id, id, session=session)


def insert_new_group(
    group_name: Optional[str],
    creator: Member,
    is_favorite: bool,
    is_constructed: bool,
    members: List[Member],
    created_at: datetime.datetime,
    session: Session_Object,
) -> MemberGroup:
    new_member_group = MemberGroup(
        group_name=group_name,
        creator_id=creator.id,
        is_favorite=is_favorite,
        is_constructed=is_constructed,
        created_at=created_at,
    )
    session.add(new_member_group)
    session.flush()

    result = []
    for member in members:
        if not is_member_valid(member, session):
            logging.error(
                f"insert_new_group: Member with id {member.id} is deleted or inactive"
            )
            raise InvalidGroupMembersException()
        if member.id is creator.id:
            raise GroupIncludesOwnerException()
        result.append(GroupMember(group_id=new_member_group.id, member_id=member.id))

    session.add_all(result)

    session.flush()

    return new_member_group


def check_group_ownership(
    group: MemberGroup, owner: Member, session: Session_Object
) -> bool:
    # session 은 session context를 강제하기 위해 넣어놓음
    if group.creator_id is not owner.id:
        return False
    else:
        return True


def assert_check_group_ownership(
    group: MemberGroup,
    owner: Member,
    session: Session_Object,
    exception: Exception = UnauthorizedGroupAccessException,
    message: str = None,
):
    if not check_group_ownership(group, owner, session):
        raise exception(message)
