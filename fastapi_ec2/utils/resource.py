import os
import logging

from typing import Tuple, Literal, Union
from pydantic import RootModel
from fastapi import UploadFile

import uuid
import io
from PIL import Image

RESOURCE_ROOT = os.getcwd()

_FILEMODEL_INDEX_FILENAME = 0
_FILEMODEL_INDEX_FILECONTENT = 1
_FILEMODEL_INDEX_FILETYPE = 2

# Define the file model
FileModel = RootModel[
    Tuple[
        str,         # File name
        bytes,       # File content
        Union[str, None]  # File type (e.g., 'image/jpeg')
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

def save_image_to_storage(image: FileModel, storage_dir: str) -> str:
    """
    Save an image to the specified storage directory.

    Args:
        image (FileModel): The image to save.
        storage_dir (str): The directory where the image will be stored.

    Returns:
        str: The relative path of the saved file.
    """
    # Ensure the storage directory exists (must be a subdirectory of RESOURCE_ROOT)
    abs_storage_dir = os.path.join(RESOURCE_ROOT, storage_dir)
    os.makedirs(abs_storage_dir, exist_ok=True)

    # Get the file extension from the original filename
    image_tuple = image.root
    original_filename = image_tuple[_FILEMODEL_INDEX_FILENAME]
    _, ext = os.path.splitext(original_filename)

    # Implement UUID with collision check on filename Practically will not happen
    while True:
        unique_filename = f"{uuid.uuid4().hex}{ext}"
        file_path = os.path.join(abs_storage_dir, unique_filename)
        if not os.path.exists(file_path):
            break

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
                    'image/jpeg': 'JPEG',
                    'image/png': 'PNG',
                    'image/gif': 'GIF',
                    'image/bmp': 'BMP',
                    'image/tiff': 'TIFF',
                    # Add other mappings if necessary
                }
                img_format = CONTENT_TYPE_TO_PIL_FORMAT.get(image_content_type, 'JPEG')

            # Set compression options
            save_kwargs = {}
            if img_format == 'JPEG':
                save_kwargs['quality'] = 85  # Compression quality
                save_kwargs['optimize'] = True
            elif img_format == 'PNG':
                save_kwargs['optimize'] = True
                save_kwargs['compress_level'] = 9  # Maximum compression

            # Save the image
            img.save(file_path, format=img_format, **save_kwargs)

        logging.info(f"Image saved to storage: {file_path}")
    except Exception as e:
        logging.error(f"Failed to save image to storage: {e}")
        raise

    # Remove RESOURCE_ROOT prefix, making it a relative path
    relative_path = os.path.relpath(file_path, RESOURCE_ROOT)
    return relative_path

def delete_image_from_storage(path: str):
    """
    Delete an image from the storage directory.

    Args:
        path (str): The relative path of the file to delete (relative to RESOURCE_ROOT).
    """
    # Construct the absolute path
    abs_path = os.path.join(RESOURCE_ROOT, path)

    # Resolve any symbolic links and get the absolute canonical path
    abs_path = os.path.realpath(abs_path)

    # Ensure that the absolute path is within RESOURCE_ROOT
    resource_root_realpath = os.path.realpath(RESOURCE_ROOT)
    if not abs_path.startswith(resource_root_realpath):
        raise ValueError("Attempted to delete a file outside of the resource root directory.")

    # Delete the file if it exists
    if os.path.exists(abs_path):
        try:
            os.remove(abs_path)
            logging.info(f"Image deleted from storage: {abs_path}")
        except Exception as e:
            logging.error(f"Failed to delete image from storage: {e}")
            raise
    else:
        logging.warning(f"File does not exist: {abs_path}")
