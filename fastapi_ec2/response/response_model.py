from pydantic import BaseModel, field_validator
from typing import Any, Optional


class ResponseModel(BaseModel):
    code: str
    message: Optional[str] = None
    data: Optional[Any] = None
