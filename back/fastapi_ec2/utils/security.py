# security.py
import os
from typing import Optional
import logging
import jwt
from jwt import PyJWTError
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from sqlalchemy.orm import Session
from dto.member_dto import MemberDTO
from service.member_service import find_member_by_id
from utils.connection_pool import get_db

# JWT settings
JWT_SECRET_KEY = os.environ.get("JWT_SECRET")
ALGORITHM = os.environ.get("JWT_ALGORITHM")

# Security scheme
security = HTTPBearer()

#TODO: 모든 API try-catch pattern으로 바꿀 것.
async def get_current_member(credentials: HTTPAuthorizationCredentials = Depends(security), Session: Session = Depends(get_db)) -> MemberDTO:
    token = credentials.credentials # Bearer blabla의 blabla 부분
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[ALGORITHM])
        id: Optional[str] = payload.get("sub")
        logging.debug(f"get_current_user: payload extracted, member_id: {id}")
        if id is None:
            logging.error("get_current_user: no id in token payload.")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Cannot validate credentials. no id in token payload.",
                headers={"WWW-Authenticate": "Bearer"},
            )
    except jwt.ExpiredSignatureError:
        logging.debug("get_current_user: Token has expired.")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except PyJWTError as e:
        logging.error(f"get_current_user: JWT error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal Server Error",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    member = find_member_by_id(id, Session)

    if(member is None):
        logging.warning(f"get_current_user: Got a valid Token with unvalid user id: {id}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Unvalid User",
            headers={"WWW-Authenticate": "Bearer"},
        )
    member_dto = MemberDTO(
        id = member.id,
        member_name=member.member_name,
        state=member.state,
        )
    return member_dto

