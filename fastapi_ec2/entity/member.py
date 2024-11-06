from enum import Enum

from sqlalchemy import BigInteger, SmallInteger, String
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base

# 0: active, 1: suspended, 2: deleted
MEMBER_STATE_ACTIVE = 0
MEMBER_STATE_SUSPENDED = 1
MEMBER_STATE_DELETED = 2


class MemberRole(Enum):
    ROLE_USER: str = "ROLE_USER"


# Models
class Member(Base):
    __tablename__ = "member"
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    member_name: Mapped[str] = mapped_column(String(255), nullable=False, unique=True)
    state: Mapped[int] = mapped_column(
        SmallInteger, default=MEMBER_STATE_ACTIVE, nullable=False
    )
    role: Mapped[str] = mapped_column(
        String(255), nullable=False, default=MemberRole.ROLE_USER.value
    )
    nickname: Mapped[str] = mapped_column(String(16), nullable=False, unique=True)

    def __repr__(self) -> str:
        return (
            f"Member(id={self.id}, member_name={self.member_name}, state={self.state})"
        )
