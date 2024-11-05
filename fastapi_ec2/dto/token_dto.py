from pydantic import BaseModel


class TokenDTO(BaseModel):
    category: str
    memberName: str
    role: str
    memberId: int
    iat: int
    exp: int