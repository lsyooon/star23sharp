from sqlalchemy import (
    BigInteger,
    Boolean,
    String,
    Text,
    DateTime,
    SmallInteger,
    CheckConstraint,
    ForeignKey,
    Double,
)
from pgvector.sqlalchemy import Vector
from sqlalchemy.orm import Mapped, mapped_column
from typing import Optional
import datetime

from .base import Base

MESSAGE_RECEIVER_INDIVIDUAL = 0
MESSAGE_RECEIVER_GROUP = 1
MESSAGE_RECEIVER_PUBLIC = 2
IMAGE_VECTOR_SIZE = 12288


class Message(Base):
    __tablename__ = "message"
    __table_args__ = (
        CheckConstraint(
            f"receiver_type IN ({MESSAGE_RECEIVER_INDIVIDUAL}, {MESSAGE_RECEIVER_GROUP}, {MESSAGE_RECEIVER_PUBLIC})",
            name="receiver_type_check",
        ),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    sender_id: Mapped[int] = mapped_column(BigInteger, nullable=False)
    receiver_type: Mapped[int] = mapped_column(
        SmallInteger, nullable=False, server_default=f"{MESSAGE_RECEIVER_INDIVIDUAL}"
    )
    hint_image_first: Mapped[str] = mapped_column(String(255), nullable=True)
    hint_image_second: Mapped[str] = mapped_column(String(255), nullable=True)
    dot_hint_image: Mapped[str] = mapped_column(String(255), nullable=True)
    title: Mapped[str] = mapped_column(String(15), nullable=False)
    content: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    hint: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
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

    def __repr__(self) -> str:
        return f"Message(id={self.id}, hint_image={self.hint_image_first}, wrote_by={self.sender_id})"
