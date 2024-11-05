from pydantic import BaseModel, field_validator
from typing import Any, Optional
from .response_codes import ResponseCodes


class ResponseModel(BaseModel):
    code: str
    message: Optional[str] = None
    data: Optional[Any] = None

    @field_validator("code")
    @classmethod
    def code_must_be_response_code(cls, v: str) -> str:
        if ResponseCodes.get(v) is None:
            raise ValueError("Invalid Response code")
        return v
