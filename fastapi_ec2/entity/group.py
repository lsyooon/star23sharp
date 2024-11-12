import datetime
from typing import List, Optional

from sqlalchemy import BigInteger, Boolean, DateTime, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base
from .member import Member


class MemberGroup(Base):
    __tablename__ = "member_group"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    group_name: Mapped[Optional[str]] = mapped_column(String(15), nullable=True)
    creator_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("member.id", ondelete="CASCADE"), nullable=False
    )
    is_favorite: Mapped[bool] = mapped_column(
        Boolean, nullable=False, server_default="false"
    )
    is_constructed: Mapped[bool] = mapped_column(
        Boolean, nullable=False, server_default="false"
    )
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False)

    # Relationships
    creator: Mapped["Member"] = relationship("Member")
    group_members: Mapped[List["GroupMember"]] = relationship(
        "GroupMember", back_populates="group", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"MemberGroup(id={self.id}, group_name={self.group_name}, creator_id={self.creator_id})"


class GroupMember(Base):
    __tablename__ = "group_member"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    group_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("member_group.id", ondelete="CASCADE"), nullable=False
    )
    member_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("member.id", ondelete="CASCADE"), nullable=False
    )

    # Relationships
    group: Mapped["MemberGroup"] = relationship(
        "MemberGroup", back_populates="group_members"
    )
    member: Mapped["Member"] = relationship("Member")

    def __repr__(self) -> str:
        return f"GroupMember(id={self.id}, group_id={self.group_id}, member_id={self.member_id})"
