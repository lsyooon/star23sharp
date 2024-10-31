from sqlalchemy import (
    BigInteger, Boolean, String, Text, TIMESTAMP, func
)
from pgvector.sqlalchemy import Vector
from sqlalchemy.orm import Mapped, mapped_column
from .base import Base

class Message(Base):
    __tablename__ = "message"
    
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    sender_id: Mapped[int] = mapped_column(BigInteger, nullable=True)
    hint_image_first: Mapped[str] = mapped_column(String(255), nullable=True)
    hint_image_second: Mapped[str] = mapped_column(String(255), nullable=True)
    dot_hint_image: Mapped[str] = mapped_column(String(255), nullable=False)
    title: Mapped[str] = mapped_column(String(15), nullable=False)
    content: Mapped[str] = mapped_column(Text, nullable=True)
    hint: Mapped[str] = mapped_column(String(20), nullable=True)
    coordinate: Mapped[list[float]] = mapped_column(Vector(2), nullable=False)
    is_treasure:Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    is_found:Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    image: Mapped[str] = mapped_column(String(255), nullable=True)
    vector: Mapped[list[float]] = mapped_column(Vector(12288), nullable=False)

    def __repr__(self) -> str:
        return f"Message(id={self.id}, hint_image={self.hint_image_first}, wrote_by={self.sender_id})"