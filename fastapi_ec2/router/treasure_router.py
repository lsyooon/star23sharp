import os
import logging
import httpx
import jwt
from typing import Optional
from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form
from sqlalchemy.orm import Session
from pydantic import BaseModel

from utils.connection_pool import get_db
from service.message_service import authorize_treasure_message, insert_new_treasure_message
from utils.security import get_current_member
from utils.resource import save_image_to_storage
from utils.distance_util import get_cosine_distance

logger = logging.getLogger(__name__)

# 서버 설정
JWT_SECRET_MESSAGE_KEY = os.environ.get("JWT_SECRET_MESSAGE_KEY")
ALGORITHM = os.environ.get("JWT_ALGORITHM")
GPU_URL = os.environ.get("GPU_URL")

#코사인 거리 임계값
THRESHOLD_COSINE_DISTANCE_LOW = 0.55 #코사인 거리가 이 값 미만이면 지나치게 유사해서 저장 불가
THRESHOLD_COSINE_DISTANCE_HIGH = 0.85 #코사인 거리가 이 값 이상이면 다른 장소로 판단

if not GPU_URL:
    logger.error("GPU_URL 환경 변수가 설정되지 않았습니다.")

treasure_router = APIRouter()

class TreasureMessageAuthResultModel(BaseModel):
    authorized:bool
    cosine_distance: Optional[float]
    token: Optional[str]

@treasure_router.post("/insert", response_model=dict)
async def insert_new_treasure(
    hint_image_first: UploadFile = File(..., description="First hint image"),
    hint_image_second: UploadFile = File(..., description="Second hint image"),
    # dot_hint_image: UploadFile = File(..., description="Dot hint image"),
    title: str = Form(..., description="Message title"),
    hint: str = Form(..., description="Text hint"),
    lat: float = Form(..., description="Latitude"),
    lon: float = Form(..., description="Longitude"),
    current_member=Depends(get_current_member),
    db: Session = Depends(get_db)
):
    """
    **디버깅용 엔드포인드. 실사용이 아님!. TODO: 추후 보안 기능 추가할 예정**
    Inserts a new treasure message with the average embedding of two hint images.
    """
    # Read file contents
    hint_image_first_content = await hint_image_first.read()
    hint_image_second_content = await hint_image_second.read()
    # dot_hint_image_content = await dot_hint_image.read()

    # Get embeddings for the two hint images
    embeddings = []
    try:
        files = [
            ('files', (hint_image_first.filename, hint_image_first_content, hint_image_first.content_type)),
            ('files', (hint_image_second.filename, hint_image_second_content, hint_image_second.content_type)),
        ]
        async with httpx.AsyncClient() as client:
            response = await client.post(f"{GPU_URL}/image/embeddings", files=files)
            response.raise_for_status()
            response_data = response.json()
            embeddings_data = response_data.get('embeddings', [])
            if len(embeddings_data) != 2:
                logger.error("Failed to get embeddings for both images.")
                raise HTTPException(status_code=500, detail="Failed to get embeddings for both images.")
            embeddings = [emb['embedding'] for emb in embeddings_data]
    except Exception as e:
        logger.error(f"Error getting embeddings: {str(e)}")
        raise HTTPException(status_code=500, detail="Error getting embeddings.")
    
    distance = get_cosine_distance(embeddings[0], embeddings[1])
    if(distance < THRESHOLD_COSINE_DISTANCE_LOW):
        raise HTTPException(status_code=500, detail=f"두 사진이 지나치게 유사합니다. 코사인 거리: {distance}")
    
    if(distance >= THRESHOLD_COSINE_DISTANCE_HIGH):
        raise HTTPException(status_code=500, detail=f"두 사진이 지나치게 다릅니다. 코사인 거리: {distance}")
    
    # Compute average vector
    vector = [(e1 + e2) / 2 for e1, e2 in zip(embeddings[0], embeddings[1])] #TODO numpy로 속도 개선

    
    # Save images to storage (Implement your own storage logic here)
    # For demonstration, let's assume you have a function save_image_to_storage
    # that saves the image and returns its URL or path.
    try:
        hint_image_first_url = save_image_to_storage(hint_image_first.filename, hint_image_first_content)
        hint_image_second_url = save_image_to_storage(hint_image_second.filename, hint_image_second_content)
        dot_hint_image_url = hint_image_first_url #setting same
    except Exception as e:
        logger.error(f"Error saving images: {str(e)}")
        raise HTTPException(status_code=500, detail="Error saving images.")

    # Insert new treasure message
    try:
        new_message = insert_new_treasure_message(
            sender_id=current_member.id,
            hint_image_first=hint_image_first_url,
            hint_image_second=hint_image_second_url,
            dot_hint_image=dot_hint_image_url,
            title=title,
            hint=hint,
            coordinate=[lat, lon],
            vector=vector,
            session=db,
        )
        db.commit()
    except Exception as e:
        logger.error(f"Error inserting new treasure message: {str(e)}")
        db.rollback()
        raise HTTPException(status_code=500, detail="Error inserting new treasure message.")

    return {"message": "Treasure message created successfully.", "distance": distance}

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
    auth_result = authorize_treasure_message(
        id,
        embedding,
        [lat, lon],
        db,
        cos_distance_threshold= THRESHOLD_COSINE_DISTANCE_HIGH
    )
    response_dict["authorized"] = auth_result[0]
    # response_dict["token"] = None
    # response_dict["cosine_distance"] = None
    if(auth_result[0] is True):
        response_dict["token"] = jwt.encode({"sub":id}, JWT_SECRET_MESSAGE_KEY, ALGORITHM)
    if(auth_result[1] is not None):
        response_dict["cosine_distance"] = auth_result[1]
    
    return TreasureMessageAuthResultModel.model_construct(**response_dict)
