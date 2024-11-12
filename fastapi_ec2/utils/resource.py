import io
import logging
import os
import uuid
from typing import Tuple, Union

import boto3
from fastapi import UploadFile
from PIL import Image
from pydantic import RootModel

# Replace local storage with Amazon S3
S3_BUCKET_NAME = os.environ["S3_BUCKET_NAME"]
S3_ACCESS_KEY_ID = os.environ["S3_ACCESS_KEY_ID"]
S3_SECRET_ACCESS_KEY = os.environ["S3_SECRET_ACCESS_KEY"]
S3_REGION = os.environ["S3_REGION"]

_FILEMODEL_INDEX_FILENAME = 0
_FILEMODEL_INDEX_FILECONTENT = 1
_FILEMODEL_INDEX_FILETYPE = 2


def _get_s3_client():
    return boto3.client(
        "s3",
        aws_access_key_id=S3_ACCESS_KEY_ID,
        aws_secret_access_key=S3_SECRET_ACCESS_KEY,
        region_name=S3_REGION,
    )


def construct_s3_link(s3_file: str):
    return f"https://{S3_BUCKET_NAME}.s3.{S3_REGION}.amazonaws.com/{s3_file}"


# Define the file model
FileModel = RootModel[
    Tuple[
        str,  # File name
        bytes,  # File content
        Union[str, None],  # File type (e.g., 'image/jpeg')
    ]
]


async def download_file(file: UploadFile) -> FileModel:
    """
    Reads a file from UploadFile and creates a FileModel object.

    Args:
        file (UploadFile): The file to download.

    Returns:
        FileModel: The downloaded file's FileModel object.
    """
    file_content = await file.read()
    return FileModel((file.filename, file_content, file.content_type))


def generate_uuid_filename(image: FileModel):
    # Generate a unique filename
    image_tuple = image.root
    original_filename = image_tuple[_FILEMODEL_INDEX_FILENAME]
    _, ext = os.path.splitext(original_filename)
    unique_filename = f"{uuid.uuid4().hex}{ext}"
    return unique_filename


def save_image_to_storage(image: FileModel, as_name: str) -> str:
    """
    Save an image to the specified storage directory in Amazon S3.

    Args:
        image (FileModel): The image to save.
        storage_dir (str): The directory in S3 where the image will be stored.

    Returns:
        str: The key of the saved file in S3.
    """
    # Get the file extension from the original filename
    image_tuple = image.root
    original_filename = image_tuple[_FILEMODEL_INDEX_FILENAME]
    _, ext = os.path.splitext(original_filename)

    try:
        # Read the image from bytes
        image_content = image_tuple[_FILEMODEL_INDEX_FILECONTENT]
        image_content_type = image_tuple[_FILEMODEL_INDEX_FILETYPE]

        # Open the image using PIL
        with Image.open(io.BytesIO(image_content)) as img:
            # Auto-resizing/compression
            max_size = (1024, 1024)  # Maximum width and height
            img.thumbnail(max_size)

            # Get the image format
            img_format = img.format
            if img_format is None:
                # Map content type to PIL format
                CONTENT_TYPE_TO_PIL_FORMAT = {
                    "image/jpeg": "JPEG",
                    "image/png": "PNG",
                    "image/gif": "GIF",
                    "image/bmp": "BMP",
                    "image/tiff": "TIFF",
                    # Add other mappings if necessary
                }
                img_format = CONTENT_TYPE_TO_PIL_FORMAT.get(image_content_type, "JPEG")

            # Set compression options
            save_kwargs = {}
            if img_format == "JPEG":
                save_kwargs["quality"] = 85  # Compression quality
                save_kwargs["optimize"] = True
            elif img_format == "PNG":
                save_kwargs["optimize"] = True
                save_kwargs["compress_level"] = 9  # Maximum compression

            # Save the image to a bytes buffer
            buffer = io.BytesIO()
            img.save(buffer, format=img_format, **save_kwargs)
            buffer.seek(0)

        # Upload the image to S3
        s3 = _get_s3_client()
        s3.upload_fileobj(
            buffer,
            S3_BUCKET_NAME,
            as_name,
            ExtraArgs={"ContentType": image_content_type},
        )

        logging.info(f"Image saved to S3: {as_name}")
    except Exception as e:
        logging.error(f"Failed to save image to S3: {e}")
        raise

    # Return the S3 key
    return as_name


def delete_image_from_storage(s3_key: str):
    """
    Delete an image from the S3 bucket.

    Args:
        s3_key (str): The key of the file to delete in S3.
    """
    try:
        s3 = _get_s3_client()
        s3.delete_object(Bucket=S3_BUCKET_NAME, Key=s3_key)
        logging.info(f"Image deleted from S3: {s3_key}")
    except Exception as e:
        logging.error(f"Failed to delete image from S3: {e}")
        raise
