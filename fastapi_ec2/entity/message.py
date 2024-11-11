import datetime
from enum import Enum
from typing import TYPE_CHECKING, List, Optional

from pgvector.sqlalchemy import Vector
from sqlalchemy import (
    ARRAY,
    BigInteger,
    Boolean,
    CheckConstraint,
    DateTime,
    Double,
    ForeignKey,
    SmallInteger,
    String,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base
from .group import MemberGroup
from .member import Member

if TYPE_CHECKING:
    from .message_box import MessageBox

IMAGE_VECTOR_SIZE = 12288


class VarcharLimit(Enum):
    TITLE: int = 15
    CONTENT: int = 100
    HINT: int = 20


class ReceiverTypes(Enum):
    INDIVIDUAL: int = 0
    GROUP_UNCONSTRUCTED: int = 1
    GROUP_CONSTRUCTED: int = 2
    PUBLIC: int = 3


class Message(Base):
    __tablename__ = "message"
    __table_args__ = (
        CheckConstraint(
            f"receiver_type IN ({ReceiverTypes.INDIVIDUAL.value}, {ReceiverTypes.GROUP_UNCONSTRUCTED.value}, {ReceiverTypes.PUBLIC.value}, {ReceiverTypes.GROUP_CONSTRUCTED.value})",
            name="receiver_type_check",
        ),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    sender_id: Mapped[int] = mapped_column(BigInteger, nullable=False)
    receiver_type: Mapped[int] = mapped_column(
        SmallInteger, nullable=False, server_default=f"{ReceiverTypes.INDIVIDUAL.value}"
    )
    receiver: Mapped[Optional[list[int]]] = mapped_column(
        ARRAY(BigInteger), nullable=True
    )
    hint_image_first: Mapped[str] = mapped_column(String(255), nullable=True)
    hint_image_second: Mapped[str] = mapped_column(String(255), nullable=True)
    dot_hint_image: Mapped[str] = mapped_column(String(255), nullable=True)
    title: Mapped[str] = mapped_column(String(VarcharLimit.TITLE.value), nullable=False)
    content: Mapped[Optional[str]] = mapped_column(
        String(VarcharLimit.CONTENT.value), nullable=True
    )
    hint: Mapped[Optional[str]] = mapped_column(
        String(VarcharLimit.HINT.value), nullable=True
    )
    lat: Mapped[float] = mapped_column(Double, nullable=True)
    lng: Mapped[float] = mapped_column(Double, nullable=True)
    coordinate: Mapped[list[float]] = mapped_column(Vector(3), nullable=True)
    is_treasure: Mapped[bool] = mapped_column(
        Boolean, nullable=False, server_default="false"
    )
    is_found: Mapped[bool] = mapped_column(
        Boolean, nullable=False, server_default="false"
    )
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False)
    image: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    vector: Mapped[list[float]] = mapped_column(
        Vector(IMAGE_VECTOR_SIZE), nullable=True
    )
    group_id: Mapped[Optional[int]] = mapped_column(
        BigInteger, ForeignKey("member_group.id", ondelete="SET NULL"), nullable=True
    )
    member: Mapped[Optional["Member"]] = relationship(
        "Member",
        primaryjoin="foreign(Message.sender_id) == Member.id",
        viewonly=True,
    )
    group: Mapped[Optional["MemberGroup"]] = relationship(
        "MemberGroup",
        viewonly=True,
    )
    message_boxes: Mapped[Optional[List["MessageBox"]]] = relationship(
        "MessageBox", viewonly=True, uselist=True
    )

    def __repr__(self) -> str:
        return f"Message(id={self.id}, hint_image={self.hint_image_first}, wrote_by={self.sender_id})"
