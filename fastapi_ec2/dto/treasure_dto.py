import datetime
from typing import List, Literal, Optional, Union, override

from entity.message import Message
from entity.message_box import MessageDirections
from pydantic import field_serializer
from response.response_model import ResponseModel
from utils.datetime_util import LocalTimeZone

from .base_dto import BaseDTO


class BaseTreasureDTOWithMemberInfo(BaseDTO):
    sender_nickname: Optional[str] = None

    created_at: datetime.datetime

    @override
    @classmethod
    def get_dto(cls, orm: Message):
        dto = super().get_dto(orm)
        if orm.member is not None:
            dto.sender_nickname = orm.member.nickname
        return dto

    @field_serializer("created_at")
    def serialize_created_at(self, created_at: datetime.datetime) -> str:
        return created_at.isoformat()


class TreasureDTO_Own(BaseTreasureDTOWithMemberInfo):
    access_level: str = "owned"
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

    image: Optional[str]

    # Non-ORM fields
    receiver_names: Optional[List[str]] = None
    receiving_group_name: Optional[str] = None

    @override
    @classmethod
    def get_dto(cls, orm: Message):
        dto = super().get_dto(orm)
        if orm.message_boxes is not None:
            dto.receiver_names = []
            for boxrow in orm.message_boxes:
                if boxrow.message_direction is MessageDirections.RECEIVED.value:
                    dto.receiver_names.append(boxrow.member.nickname)
            if len(dto.receiver_names) == 0:
                dto.receiver_names = None
        if orm.group is not None:
            dto.receiving_group_name = (
                orm.group.group_name if orm.group.group_name is not None else None
            )
        return dto


class TreasureDTO_Opened(BaseTreasureDTOWithMemberInfo):
    access_level: str = "opened"
    id: int
    sender_id: int
    receiver_type: int
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
    image: Optional[str]


class TreasureDTO_Undiscovered(BaseTreasureDTOWithMemberInfo):
    access_level: str = "undiscovered"
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
    data: dict[
        Literal["treasures"],
        List[Union[TreasureDTO_Own, TreasureDTO_Opened, TreasureDTO_Undiscovered]],
    ]
