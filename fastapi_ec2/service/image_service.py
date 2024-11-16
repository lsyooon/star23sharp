# services/image_service.py
import logging
import os
from typing import List, Tuple, Union

import httpx
from response.exceptions import (
    EmbeddingsCountMismatchException,
    GPUProxyConnectionException,
    GPUProxyServerException,
    InvalidInputException,
    NSFWImageDetectedException,
)
from starlette.datastructures import UploadFile
from utils.resource import _FILEMODEL_INDEX_FILECONTENT, FileModel, download_file

# 서버 설정 CONFIG
GPU_URL = os.environ["GPU_URL"]
BACKUP_GPU_URL = os.environ.get("BACKUP_GPU_URL")

# 프록시 서버 엔드포인트 정의
PIXELIZE_ENDPOINT = "/image/pixelize"
EMBEDDING_ENDPOINT = "/image/embedding"
EMBEDDINGS_ENDPOINT = "/image/embeddings"
NSFW_ENDPOINT = "/image/nsfw"

# 엔드포인트 파라메터 기본값들
PIXELIZE_DEFAULT_KERNEL = 7
PIXELIZE_DEFAULT_PIXEL_SIZE = 48


async def proxy_file_request(
    endpoint: str, files: dict, data: dict = None
) -> httpx.Response:
    """
    Send request to the proxy server.
    Try the main GPU server first; if connection fails or server error occurs, try the backup GPU server.
    """

    async def send_request(url):
        async with httpx.AsyncClient() as client:
            response = await client.post(url, files=files, data=data)
            return response

    main_url = f"{GPU_URL}{endpoint}"
    backup_url = f"{BACKUP_GPU_URL}{endpoint}" if BACKUP_GPU_URL else None

    # Try the main GPU server first
    try:
        response = await send_request(main_url)
        if response.status_code == 200:
            return response
        elif response.status_code >= 500:
            # Server error, try backup server if available
            logging.error(f"Server error at main GPU server: {response.status_code}")
            if backup_url:
                response = await send_request(backup_url)
                if response.status_code == 200:
                    return response
                else:
                    logging.error(
                        f"Server error at backup GPU server: {response.status_code}"
                    )
                    raise GPUProxyServerException()
            else:
                raise GPUProxyServerException()
        else:
            # Client error, do not retry
            logging.error(f"Client error at main GPU server: {response.status_code}")
            raise InvalidInputException(
                "GPU 서버에서 온 응답 관련 오류입니다. Client 와는 관계가 없을 수도 있습니다."
            )
    except (httpx.ConnectError, httpx.ConnectTimeout, httpx.ReadTimeout, httpx.ReadError) as e:
        logging.error(f"Connection error to main GPU server: {e}")
        # Try the backup GPU server
        if backup_url:
            try:
                response = await send_request(backup_url)
                if response.status_code == 200:
                    return response
                else:
                    logging.error(f"Error at backup GPU server: {response.status_code}")
                    raise GPUProxyServerException()
            except Exception as e2:
                logging.error(f"Connection error to backup GPU server: {e2}")
                raise GPUProxyConnectionException()
        else:
            raise GPUProxyConnectionException()


async def pixelize_image_service(
    file: Union[UploadFile, FileModel],
    kernel_size: int = PIXELIZE_DEFAULT_KERNEL,
    pixel_size: int = PIXELIZE_DEFAULT_PIXEL_SIZE,
) -> FileModel:
    """
    Send a request to the proxy server to apply a pixelation effect to the image.
    """
    # Validate inputs
    if kernel_size < 1 or pixel_size < 1:
        logging.error(
            f"pixelize_image_service: kernel size: {kernel_size} and pixel_size: {pixel_size} must be at least 1!"
        )
        raise InvalidInputException()

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
    Send a request to the proxy server to get the embedding of an image.
    """
    if isinstance(file, UploadFile):
        file = await download_file(file)

    response = await proxy_file_request(EMBEDDING_ENDPOINT, files={"file": file.root})
    return response


async def get_embedding_of_two_images(
    file_1: Union[UploadFile, FileModel], file_2: Union[UploadFile, FileModel]
) -> Tuple[List[float], List[float]]:
    """
    Send a request to the proxy server to get the embeddings of two images.
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

    if response_data.get("nsfw") == "unsafe":
        raise NSFWImageDetectedException()

    embeddings = response_data.get("embeddings", [])

    if len(embeddings) != 2:
        raise EmbeddingsCountMismatchException()

    embedding_1 = embeddings[0]["embedding"]
    embedding_2 = embeddings[1]["embedding"]

    return embedding_1, embedding_2


async def check_nsfw_service(imagefile: Union[UploadFile, FileModel]) -> bool:
    if isinstance(imagefile, UploadFile):
        imagefile = await download_file(imagefile)

    response = await proxy_file_request(NSFW_ENDPOINT, files={"file": imagefile.root})
    response_json = response.json()
    if response_json["nsfw"] == "safe":
        return True
    elif response_json["nsfw"] == "unsafe":
        return False
    else:
        logging.exception("NSFW 체크 중에 에러가 발생했습니다.")
        raise GPUProxyServerException("NSFW 체크 중에 에러가 발생했습니다.")
