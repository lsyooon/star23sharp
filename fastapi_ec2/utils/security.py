# security.py
import logging
import os
from typing import Tuple
import jwt
from dto.member_dto import MemberDTO
from dto.token_dto import TokenDTO
from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jwt import InvalidSignatureError, PyJWTError
from pydantic import ValidationError
from response.exceptions import (
    ExpiredTokenException,
    InvalidTokenException,
    MemberNotFoundException,
    UnhandledException,
)
from service.member_service import assert_member_by_id
from sqlalchemy.orm import Session
from utils.connection_pool import get_db

# JWT settings
JWT_SECRET_KEY = os.environ.get("JWT_SECRET")
ALGORITHM = os.environ.get("JWT_ALGORITHM")

# Security scheme
security = HTTPBearer()


async def get_current_member(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    Session: Session = Depends(get_db),
) -> Tuple[MemberDTO, str]:
    token = credentials.credentials  # Bearer blabla의 blabla 부분
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[ALGORITHM])
        try:
            token_obj = TokenDTO.model_validate(payload)
        except ValidationError:
            raise InvalidTokenException()
        except Exception:
            logging.exception("get_current_member: exception occured")
            raise InvalidTokenException()
    except jwt.ExpiredSignatureError:
        raise ExpiredTokenException()
    except InvalidSignatureError:
        raise InvalidTokenException("InvalidSignatureError. JWT SECRET이 잘못된 것으로 추정됩니다.")
    except PyJWTError:
        logging.exception("get_current_user: JWT error.")
        raise UnhandledException("get_current_user: JWT error.")

    member = assert_member_by_id(token_obj.memberId, Session)
    if member.member_name != token_obj.memberName:
        logging.warning(
            f"get_current_member: 토큰: {token} 의 memberName 과 DB의 member_name 이 일치하지 않습니다!."
        )
        raise InvalidTokenException()
    if member.role != token_obj.role:
        logging.warning(
            f"get_current_member: 토큰: {token} 의 role 과 DB의 role 이 일치하지 않습니다!."
        )
        raise InvalidTokenException()
    member_dto = MemberDTO.get_dto(member)
    return member_dto, token
