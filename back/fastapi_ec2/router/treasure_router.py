import os
import logging
import httpx
import jwt
from typing import Optional
from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form
from sqlalchemy.orm import Session
from pydantic import BaseModel

from utils.connection_pool import get_db
from service.message_service import authorize_treasure_message
from utils.security import get_current_member

logger = logging.getLogger(__name__)

# 서버 설정
JWT_SECRET_MESSAGE_KEY = os.environ.get("JWT_SECRET_MESSAGE_KEY")
ALGORITHM = os.environ.get("JWT_ALGORITHM")
GPU_URL = os.environ.get("GPU_URL")

if not GPU_URL:
    logger.error("GPU_URL 환경 변수가 설정되지 않았습니다.")

treasure_router = APIRouter()


class TreasureMessageAuthResultModel(BaseModel):
    authorized:bool
    cosine_distance: Optional[float]
    token: Optional[str]

@treasure_router.post("/authorize", response_model = TreasureMessageAuthResultModel)
async def authorize_treasure(
    file: UploadFile = File(..., description="테스트할 이미지"),
    id: int = Form(..., description="보물 메시지의 ID"),
    lat: float = Form(..., description="현재 위도"),
    lon: float = Form(..., description="현재 경도"),
    _ = Depends(get_current_member),
    db: Session = Depends(get_db)
):
    """
    보물 메시지 인증을 처리하는 엔드포인트.

    이미지를 임베딩 서버로 전송하여 임베딩 벡터를 얻은 후,
    보물 메시지 인증 서비스를 호출합니다.

    Args:
        file (UploadFile): 테스트할 이미지 파일.
        id (int): 보물 메시지의 ID.
        lat (float): 현재 위도.
        lon (float): 현재 경도.

    Returns:
        {
            authorized: boolean 인증 결과.
            cosine_distance: Optional[float] 코사인 거리. null이면 요청자의 위치가 인증하려는 메세지에 대해 너무 먼 것입니다.
            token: Optional[str] 인증 성공 시 반환되는 token 값. 보물 메세지 내용을 요청하는데 사용할 수 있습니다.
        }
    """
    if not GPU_URL:
        logger.error("GPU_URL이 설정되지 않았습니다.")
        raise HTTPException(status_code=500, detail="서버 구성 오류")

    embedding_server_url = GPU_URL
    endpoint = "/image/embedding"
    url = f"{embedding_server_url}{endpoint}"

    # 파일 내용 읽기
    try:
        file_content = await file.read()
    except Exception as e:
        logger.error(f"파일을 읽는 중 오류 발생: {str(e)}")
        raise HTTPException(status_code=400, detail="유효하지 않은 파일입니다.")

    files = {'file': (file.filename, file_content, file.content_type)}

    # 임베딩 서버로 요청 전송
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(url, files=files)
            response.raise_for_status()
            response_json = response.json()
            embedding = response_json.get("embedding")
            if not embedding:
                logger.error("임베딩 서버에서 임베딩을 반환하지 않았습니다.")
                raise HTTPException(status_code=500, detail="임베딩 서버 오류")
    except httpx.HTTPError as e:
        logger.error(f"임베딩을 가져오는 중 오류 발생: {str(e)}")
        raise HTTPException(status_code=500, detail="임베딩 서버 연결 오류")

    response_dict = {}
    # 보물 메시지 인증 서비스 호출
    auth_result = authorize_treasure_message(id, embedding, [lat, lon], db)
    response_dict["authorized"] = auth_result[0]
    # response_dict["token"] = None
    # response_dict["cosine_distance"] = None
    if(auth_result[0] is True):
        response_dict["token"] = jwt.encode({"sub":id}, JWT_SECRET_MESSAGE_KEY, ALGORITHM)
    if(auth_result[1] is not None):
        response_dict["cosine_distance"] = auth_result[1]
    
    return TreasureMessageAuthResultModel.model_construct(**response_dict)
