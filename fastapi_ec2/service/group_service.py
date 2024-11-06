import datetime
import logging
from typing import List, Optional

from entity.group import GroupMember, MemberGroup
from entity.member import Member
from response.exceptions import InvalidGroupMembersException
from sqlalchemy.orm.session import Session as Session_Object

from .member_service import find_members_by_id_no_validation, is_member_valid
from .simple_find import find_by_attribute


def find_group_by_id(id: int, session: Session_Object) -> Optional[MemberGroup]:
    return find_by_attribute(MemberGroup, MemberGroup.id, id, session=session)


def insert_new_group(
    group_name: Optional[str],
    creator: Member,
    is_favorite: bool,
    is_constructed: bool,
    member_ids: List[int],
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

    members = find_members_by_id_no_validation(member_ids, session)
    if len(members) != len(member_ids):
        logging.error("insert_new_group: 멤버들 중 일부가 존재하지 않음")
        raise InvalidGroupMembersException()

    result = []
    for member in members:
        if not is_member_valid(member):
            logging.error(
                f"insert_new_group: Member with id {member.id} is deleted or inactive"
            )
            raise InvalidGroupMembersException()

        result.append(GroupMember(group_id=new_member_group.id, member_id=member.id))

    session.add_all(result)

    session.flush()

    return new_member_group
