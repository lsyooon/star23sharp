from typing import Optional

from response.response_model import ResponseModel

from .base_dto import BaseDTO


class TreasureDTO_Own(BaseDTO):
    id: int
    sender_id: int
    receiver_type: int
    dot_hint_image: str
    title: str
    content: Optional[str]
    lat: float
    lng: float
    group_id: Optional[int]
    image: Optional[str]


class ResponseTreasureDTO_Own(ResponseModel):
    data: Optional[TreasureDTO_Own] = None


class TreasureDTO_Opened(BaseDTO):
    id: int
    sender_id: int
    title: str
    content: Optional[str]
    lat: float
    lng: float
    image: Optional[str]


class ResponseTreasureDTO_Opened(ResponseModel):
    data: Optional[TreasureDTO_Opened] = None
