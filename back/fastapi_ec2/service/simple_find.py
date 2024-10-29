from typing import Optional, Any
from sqlalchemy.orm.session import Session as Session_Object
from sqlalchemy.orm.attributes import InstrumentedAttribute
from sqlalchemy import select
from entity.base import Base

def find_by_attribute(
    target_class : Base, #TODO: proper hinting
    target: InstrumentedAttribute, 
    attr: Any, 
    session: Session_Object
) -> Optional[Base]:
    stmt = select(target_class).where(target == attr)
    return session.scalar(stmt)
