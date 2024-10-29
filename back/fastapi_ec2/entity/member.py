from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import BigInteger, String, SmallInteger
from .base import Base

# Models
class Member(Base):
    __tablename__ = 'members'
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    member_name: Mapped[str] = mapped_column(String(255), nullable=False, unique=True)
    state: Mapped[int] = mapped_column(SmallInteger, default=0, nullable=False)
    def __repr__(self) -> str:
        return f"Member(id={self.id}, member_name={self.member_name}, state={self.state})"
