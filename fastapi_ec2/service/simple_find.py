from typing import Optional, List, Any, Type
from sqlalchemy.orm.session import Session as Session_Object
from sqlalchemy.orm.attributes import InstrumentedAttribute
from sqlalchemy import select
from entity.base import Base


def find_multiple_by_attribute(
    target_class: Type[Base],
    target: InstrumentedAttribute,
    values: List[Any],
    session: Session_Object,
) -> List[Base]:
    """Find multiple instances by a specified attribute."""
    stmt = select(target_class).where(target.in_(values))
    return list(session.scalars(stmt))


def find_by_attribute(
    target_class: Type[Base],
    target: InstrumentedAttribute,
    value: Any,
    session: Session_Object,
) -> Optional[Base]:
    """Find a single instance by a specified attribute."""
    result = find_multiple_by_attribute(target_class, target, [value], session)
    return result[0] if result else None
