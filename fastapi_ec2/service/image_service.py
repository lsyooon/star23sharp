# services/image_service.py
import logging
import os
import httpx

from typing import List, Tuple, Union
from starlette.datastructures import UploadFile
from fastapi import HTTPException

from utils.resource import FileModel, download_file, _FILEMODEL_INDEX_FILECONTENT

from response.response_model import ResponseModel

# 서버 설정 CONFIG
GPU_URL = os.environ.get("GPU_URL", None)

# 프록시 서버 엔드포인트 정의
PIXELIZE_ENDPOINT = "/image/pixelize"
EMBEDDING_ENDPOINT = "/image/embedding"
EMBEDDINGS_ENDPOINT = "/image/embeddings"

# 엔드포인트 파라메터 기본값들
PIXELIZE_DEFAULT_KERNEL = 7
PIXELIZE_DEFAULT_PIXEL_SIZE = 48


async def proxy_file_request(
    endpoint: str, files: dict, data: dict = None
) -> httpx.Response:
    """
    프록시 서버로 요청을 보냅니다.

    매개변수:
        endpoint (str): 프록시 서버의 엔드포인트.
        files (dict): 업로드할 파일들.
        data (dict, optional): 추가 데이터.

    반환값:
        httpx.Response: 프록시 서버의 응답.
    """
    url = f"{GPU_URL}{endpoint}"
    async with httpx.AsyncClient() as client:
        response = await client.post(url, files=files, data=data)
    if response.status_code != 200:
        raise HTTPException(
            status_code=response.status_code, detail=ResponseModel(code="L0014")
        )
    return response


async def pixelize_image_service(
    file: Union[UploadFile, FileModel],
    kernel_size: int = PIXELIZE_DEFAULT_KERNEL,
    pixel_size: int = PIXELIZE_DEFAULT_PIXEL_SIZE,
) -> FileModel:
    """
    이미지에 픽셀화 효과를 적용하기 위해 프록시 서버로 요청을 보냅니다.

    매개변수:
        file (Union[UploadFile, FileModel]): 픽셀화할 이미지 파일.
        kernel_size (int): 픽셀화 효과를 위한 커널 크기.
        pixel_size (int): 픽셀화 효과를 위한 픽셀 크기.

    반환값:
        httpx.Response: 프록시 서버의 응답.
    """
    # 값 검증
    if kernel_size < 1 or pixel_size < 1:
        logging.error(
            f"pixelize_image_service: kernel size: {kernel_size} 와 pixel_size: {pixel_size} 중 하나 이상이 1 미만입니다!"
        )
        raise ValueError("E0001")

    if isinstance(file, UploadFile):
        file = await download_file(file)
    data = {
        "kernel_size": str(kernel_size),
        "pixel_size": str(pixel_size),
    }
    response = await proxy_file_request(
        PIXELIZE_ENDPOINT, files={"file": file.root}, data=data
    )
    returning_list = list(file.root)
    returning_list[_FILEMODEL_INDEX_FILECONTENT] = response.content
    return FileModel(tuple(returning_list))


async def get_embedding_service(file: Union[UploadFile, FileModel]) -> httpx.Response:
    """
    이미지의 임베딩을 얻기 위해 프록시 서버로 요청을 보냅니다.

    매개변수:
        file (Union[UploadFile, FileModel]): 임베딩을 얻을 이미지 파일.

    반환값:
        httpx.Response: 프록시 서버의 응답.
    """
    if isinstance(file, UploadFile):
        file = await download_file(file)

    response = await proxy_file_request(EMBEDDING_ENDPOINT, files={"file": file.root})
    return response


async def get_embedding_of_two_images(
    file_1: Union[UploadFile, FileModel], file_2: Union[UploadFile, FileModel]
) -> Tuple[List[float], List[float]]:
    """
    두 이미지의 임베딩을 얻기 위해 프록시 서버로 요청을 보냅니다.

    매개변수:
        file_1 (Union[UploadFile, FileModel]): 첫 번째 이미지 파일.
        file_2 (Union[UploadFile, FileModel]): 두 번째 이미지 파일.

    반환값:
        tuple: 두 이미지의 임베딩.
    """
    if isinstance(file_1, UploadFile):
        file_1 = await download_file(file_1)
    if isinstance(file_2, UploadFile):
        file_2 = await download_file(file_2)

    files = [
        ("files", file_1.root),
        ("files", file_2.root),
    ]
    response = await proxy_file_request(EMBEDDINGS_ENDPOINT, files=files)

    response_data = response.json()
    embeddings = response_data.get("embeddings", [])

    if len(embeddings) != 2:
        raise HTTPException(status_code=500, detail=ResponseModel(code="L0015"))

    embedding_1 = embeddings[0]["embedding"]
    embedding_2 = embeddings[1]["embedding"]

    return embedding_1, embedding_2
