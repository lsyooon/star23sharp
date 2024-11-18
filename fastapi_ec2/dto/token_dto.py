from typing import Literal

from pydantic import BaseModel


class TokenDTO(BaseModel):
    category: Literal["access"]
    memberName: str
    role: str
    memberId: int
    iat: int
    exp: int
