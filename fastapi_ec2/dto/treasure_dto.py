import datetime
from typing import List, Literal, Optional, Union

from response.response_model import ResponseModel

from .base_dto import BaseDTO


class TreasureDTO_Own(BaseDTO):
    id: int
    sender_id: int
    receiver_type: int
    receiver: Optional[List[int]]
    hint_image_first: str
    hint_image_second: str
    dot_hint_image: str
    title: str
    content: Optional[str]
    hint: Optional[str]
    lat: float
    lng: float
    is_treasure: Literal[True]
    is_found: bool
    created_at: datetime.datetime
    image: Optional[str]


class TreasureDTO_Opened(BaseDTO):
    id: int
    sender_id: int
    receiver_type: int
    receiver: Optional[List[int]]
    hint_image_first: str
    hint_image_second: str
    dot_hint_image: str
    title: str
    content: Optional[str]
    hint: Optional[str]
    lat: float
    lng: float
    is_treasure: Literal[True]
    is_found: bool
    created_at: datetime.datetime
    image: Optional[str]


class TreasureDTO_Undiscovered(BaseDTO):
    id: int
    sender_id: int
    receiver_type: int
    dot_hint_image: str
    title: str
    hint: Optional[str]
    lat: float
    lng: float
    is_treasure: Literal[True]
    is_found: bool
    created_at: datetime.datetime


class ResponseTreasureDTO_Own(ResponseModel):
    code: Literal["200"]
    data: Optional[TreasureDTO_Own] = None


class ResponseTreasureDTO_Opened(ResponseModel):
    code: Literal["200"]
    data: Optional[TreasureDTO_Opened] = None


class ResponseTreasureDTO_Undiscovered(ResponseModel):
    code: Literal["200"]
    data: dict[Literal["treasures"], List[TreasureDTO_Undiscovered]]

class ResponseTreasureDTO_Any(ResponseModel):
    code: Literal["200"]
    data: dict[Literal["treasures"], List[Union[TreasureDTO_Own,TreasureDTO_Opened,TreasureDTO_Undiscovered]]]