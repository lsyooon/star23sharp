from pydantic import BaseModel
from typing import List
from fastapi import APIRouter, UploadFile, File, Form, Response, Depends
from service.image_service import (
    pixelize_image_service,
    get_embedding_service,
    get_embedding_of_two_images
)

from utils.resource import _FILEMODEL_INDEX_FILECONTENT
from utils.security import get_current_member
from utils.distance_util import get_cosine_distance

class EmbeddingResponseModel(BaseModel):
    """
    임베딩 응답 모델

    속성:
        embedding (List[float]): 이미지 임베딩 벡터
    """
    embedding: List[float]

image_router = APIRouter()

@image_router.post("/pixelize", response_class=Response)
async def pixelize_image(
    file: UploadFile = File(..., description="픽셀화할 이미지 파일"),
    kernel_size: int = Form(default=7, description="픽셀화 효과를 위한 커널 크기. 클 수록 가까운 픽셀끼리의 색 전환이 부드러워짐."),
    pixel_size: int = Form(default=48, description="픽셀화 효과를 위한 픽셀 크기. 클 수록 결과물의 픽셀 크기가 커짐."),
    _ = Depends(get_current_member)
):
    """
    업로드된 이미지에 픽셀화 효과를 적용합니다.

    매개변수:
        file (UploadFile): 픽셀화할 이미지 파일.
        kernel_size (int, optional): 픽셀화 효과를 위한 커널 크기. 기본값은 7.
        pixel_size (int, optional): 픽셀화 효과를 위한 픽셀 크기. 기본값은 48.

    반환값:
        Response: PNG 형식의 픽셀화된 이미지.
    """
    responsed_file = await pixelize_image_service(file, kernel_size, pixel_size)
    return Response(
        content=responsed_file.root[_FILEMODEL_INDEX_FILECONTENT],
        media_type="image/png",
        status_code=200
    )

@image_router.post("/embedding", response_model=EmbeddingResponseModel)
async def get_embedding(
    file: UploadFile = File(..., description="임베딩을 얻을 이미지"),
    _ = Depends(get_current_member)
):
    """
    이미지의 임베딩을 가져옵니다.

    매개변수:
        file (UploadFile): 임베딩을 얻을 이미지 파일.

    반환값:
        EmbeddingResponseModel: 이미지의 임베딩.
    """
    response = await get_embedding_service(file)
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
    두 이미지의 유사도를 계산하여 반환합니다.

    매개변수:
        file_1 (UploadFile): 첫번째 이미지 파일.
        file_2 (UploadFile): 두번째 이미지 파일.

    반환값:
        float: 두 이미지 임베딩의 코사인 거리.
    """
    embedding_1, embedding_2 = await get_embedding_of_two_images(file_1, file_2)
    distance = float(get_cosine_distance(embedding_1, embedding_2))
    return distance
