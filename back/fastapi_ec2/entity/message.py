from sqlalchemy import (
    BigInteger, Boolean, ForeignKey, String, Text, TIMESTAMP, func
)
from pgvector.sqlalchemy import Vector
from sqlalchemy.orm import relationship, Mapped, mapped_column
from .base import Base
from .member import Member

class TreasureMessage(Base):
    __tablename__ = "treasure_messages"
    
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    message_id: Mapped[int] = mapped_column(ForeignKey("messages.id"), nullable=False)
    hint_image: Mapped[str] = mapped_column(String(255), nullable=False)
    hint_vector: Mapped[list[float]] = mapped_column(Vector(12288), nullable=False)
    hint_text: Mapped[str] = mapped_column(String(100), nullable=True)
    dot_hint_image: Mapped[str] = mapped_column(String(255), nullable=False)
    coordinate: Mapped[list[float]] = mapped_column(Vector(2), nullable=False)

    # Define a relationship to messages referencing the treasure message
    message: Mapped["Message"] = relationship(back_populates="treasure_message")

    def __repr__(self) -> str:
        return f"TreasureMessage(id={self.id}, hint_image={self.hint_image}, wrote_by={self.message.writer_id})"

class Message(Base):
    __tablename__ = "messages"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    writer_id: Mapped[int] = mapped_column(ForeignKey("members.id"), nullable=False)
    is_treasure:Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    title: Mapped[str] = mapped_column(String(50), nullable=True)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[str] = mapped_column(TIMESTAMP, server_default=func.current_timestamp(), nullable=False)
    image: Mapped[str] = mapped_column(String(255), nullable=True)

    # Define a relationship back to the treasure message
    treasure_message: Mapped["TreasureMessage"] = relationship(back_populates="message")
    member: Mapped["Member"] = relationship()

    def __repr__(self) -> str:
        return f"Message(id={self.id}, writer_id={self.writer_id}, title={self.title})"
