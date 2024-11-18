from .base_dto import BaseDTO


class MemberDTO(BaseDTO):
    id: int
    member_name: str
    state: int
    role: str
    nickname: str
