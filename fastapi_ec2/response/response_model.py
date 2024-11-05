from typing import Any, Optional

from pydantic import BaseModel


class ResponseModel(BaseModel):
    code: str
    message: Optional[str] = None
    data: Optional[Any] = None
