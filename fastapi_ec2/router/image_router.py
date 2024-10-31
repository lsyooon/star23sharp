import os
import logging
import httpx
from typing import List
from pydantic import BaseModel
from fastapi import APIRouter, HTTPException, Depends
from fastapi import UploadFile, File, Form, Response

from utils.security import get_current_member
from utils.distance_util import get_cosine_distance

# 서버 CONFIG
GPU_URL = os.environ.get("GPU_URL", None)

image_router = APIRouter()

class EmbeddingResponseModel(BaseModel):
    embedding: List[float]

@image_router.post("/pixelize", response_class=Response)
async def pixelize_image(
    file: UploadFile = File(..., description="픽셀화할 이미지 파일"),
    kernel_size: int = Form(default=7, description="픽셀화 효과를 위한 커널 크기. 클 수록 가까운 픽셀끼리의 색 전환이 부드러워짐."),
    pixel_size: int = Form(default=48, description="픽셀화 효과를 위한 픽셀 크기. 클 수록 결과물의 픽셀 크기가 커짐."),
    _ = Depends(get_current_member)
):
    """
    업로드된 이미지에 픽셀화 효과를 적용하기 위해 백엔드 서버로 요청을 프록시합니다.

    이 엔드포인트는 프록시로 동작하며, 수신된 이미지와 파라미터를 프록시 서버로 전달한 후,
    클라이언트에게 응답을 반환합니다.

    매개변수:
        file (UploadFile): 픽셀화할 이미지 파일.
        kernel_size (int, optional): 픽셀화 효과를 위한 커널 크기. 클 수록 가까운 픽셀끼리의 색 전환이 부드러워짐. 기본값은 7. 
        pixel_size (int, optional): 픽셀화 효과를 위한 픽셀 크기. 클 수록 결과물의 픽셀 크기가 커짐. 기본값은 48.

    반환값:
        Response: PNG 형식의 픽셀화된 이미지.
    """
    # 프록시 서버 URL 정의
    proxy_server_url = GPU_URL
    endpoint = "/image/pixelize"
    url = f"{proxy_server_url}{endpoint}"

    # 파일 내용 읽기
    file_content = await file.read()
    files = {'file': (file.filename, file_content, file.content_type)}

    # 폼 데이터 준비
    data = {
        'kernel_size': str(kernel_size),
        'pixel_size': str(pixel_size),
    }

    # httpx AsyncClient를 사용하여 비동기 요청 수행
    async with httpx.AsyncClient() as client:
        response = await client.post(url, files=files, data=data)

    # 클라이언트에게 응답 반환
    return Response(
        content=response.content,
        media_type="image/png",
        status_code=response.status_code
    )

@image_router.post("/embedding", response_model=EmbeddingResponseModel)
async def get_embedding(
    file: UploadFile = File(..., description="임베딩을 얻을 이미지"),
    _ = Depends(get_current_member)
):
    """
    이미지의 임베딩을 가져옵니다.
    반환값:
        Response: List[float]: 임베딩. 길이 약 12000
    """
    # 프록시 서버 URL 정의
    proxy_server_url = GPU_URL
    endpoint = "/image/embedding"
    url = f"{proxy_server_url}{endpoint}"

    # 파일 내용 읽기
    file_content = await file.read()
    files = {'file': (file.filename, file_content, file.content_type)}

    # httpx AsyncClient를 사용하여 비동기 요청 수행
    async with httpx.AsyncClient() as client:
        response = await client.post(url, files=files)

    # 클라이언트에게 응답 반환
    return Response(
        content=response.content,
        media_type=response.headers.get('content-type'),
        status_code=response.status_code
    )

@image_router.post("/compare")
async def compare_image(
    file_1: UploadFile = File(..., description="첫번째 이미지"),
    file_2: UploadFile = File(..., description="두번째 이미지"),
    _ = Depends(get_current_member)
) -> float:
    """
    두 이미지를 받아 AI모델에 대한 둘 간의 유사도를 계산하여 반환합니다.

    매개변수:
        file_1 (UploadFile): 첫번째 이미지 파일.
        file_2 (UploadFile): 두번째 이미지 파일.

    반환값:
        float: 두 이미지 임베딩의 유사도 값. 코사인 거리로 0 ~ 2 사이의 값이 나옵니다..
    """
    embedding_server_url = GPU_URL
    endpoint = "/image/embeddings"  # 여러 파일을 위한 엔드포인트 주의
    url = f"{embedding_server_url}{endpoint}"

    # 파일 내용 읽기
    file_1_content = await file_1.read()
    file_2_content = await file_2.read()

    # 업로드할 파일 준비
    files = [
        ('files', (file_1.filename, file_1_content, file_1.content_type)),
        ('files', (file_2.filename, file_2_content, file_2.content_type)),
    ]

    # httpx AsyncClient를 사용하여 비동기 요청 수행
    async with httpx.AsyncClient() as client:
        response = await client.post(url, files=files)

    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail="임베딩 서버 오류")

    response_data = response.json()
    embeddings = response_data.get('embeddings', [])
    if len(embeddings) != 2:
        raise HTTPException(status_code=500, detail="두 이미지 모두의 임베딩을 가져오는데 실패했습니다")

    embedding_1 = embeddings[0]['embedding']
    embedding_2 = embeddings[1]['embedding']

    # 코사인 거리 계산
    distance = get_cosine_distance(embedding_1, embedding_2)

    return distance
