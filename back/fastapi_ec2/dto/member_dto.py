from pydantic import BaseModel

# Models
class MemberDTO(BaseModel):
    id: int 
    member_name: str
    state: int
