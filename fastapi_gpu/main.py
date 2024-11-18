import io
from typing import List

import torch
import torchvision.transforms as T
from fastapi import FastAPI, File, Form, Response, UploadFile
from models.boq_embeddings import BOQEmbeddings
from models.pixel_effect_module import PixelEffectModule
from PIL import Image, ImageOps
from transformers import pipeline

NSFW_THRESHOLD = 0.8

app = FastAPI()

# Initialize the models
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
embedding_model = BOQEmbeddings(device=device)
pixel_effect_model = PixelEffectModule(device=device)

nsfw_filter = pipeline(
    "image-classification",
    model="MichalMlodawski/nsfw-image-detection-large",
    device=device,
)

# Transformation to convert tensors to PIL Images
to_pil = T.ToPILImage()


def is_nsfw_safe(image: Image) -> bool:
    nsfw_result = nsfw_filter(image)
    for dict in nsfw_result:
        if dict["label"] == "UNSAFE":
            if dict["score"] > NSFW_THRESHOLD:  # label: UNSAFE
                return False
            break
    return True


def _open_image(input_file):
    """
    Open an image file and apply EXIF orientation correction.

    Args:
        input_file: The input image file.

    Returns:
        PIL.Image.Image: The opened and correctly oriented image.
    """
    image = Image.open(input_file)
    return ImageOps.exif_transpose(image).convert("RGB")


@app.post("/image/pixelize")
async def pixelize_image(
    file: UploadFile = File(..., description="Image file to be pixelized"),
    kernel_size: int = Form(
        default=7, description="Kernel size for pixelization effect"
    ),
    pixel_size: int = Form(
        default=48, description="Pixel size for pixelization effect"
    ),
):
    """
    Apply a pixelization effect to an uploaded image.

    This endpoint allows users to apply a pixelization effect to an image with customizable kernel and pixel sizes.

    Args:
        file (UploadFile): The image file to be pixelized.
        kernel_size (int, optional): The kernel size for the pixelization effect. Defaults to 7.
        pixel_size (int, optional): The pixel size for the pixelization effect. Defaults to 48.

    Returns:
        Response: The pixelized image in PNG format.
    """
    contents = await file.read()
    image = _open_image(io.BytesIO(contents))
    with torch.no_grad():
        result_tensor = pixel_effect_model.filter_img(
            image, param_kernel_size=kernel_size, param_pixel_size=pixel_size
        )
    result_image = to_pil(result_tensor.cpu().clamp(0, 1))
    buf = io.BytesIO()
    result_image.save(buf, format="PNG")
    return Response(content=buf.getvalue(), media_type="image/png")


@app.post("/image/embedding")
async def embed_image(
    file: UploadFile = File(..., description="Image file to generate embedding")
):
    """
    Generate an embedding vector for an uploaded image.

    Args:
        file (UploadFile): The image file for which to generate the embedding.

    Returns:
        dict: A JSON object containing the embedding vector.
    """
    contents = await file.read()
    image = _open_image(io.BytesIO(contents))
    # if not is_nsfw_safe(image):
    #     return {"nsfw": "unsafe"}
    embedding_tensor = embedding_model.embed_image(image)
    embedding_list = embedding_tensor.cpu().numpy().tolist()
    return {"nsfw": "safe", "embedding": embedding_list}


@app.post("/image/embeddings")
async def embed_images(
    files: List[UploadFile] = File(
        ..., description="List of image files to generate embeddings"
    )
):
    """
    Generate embedding vectors for multiple uploaded images.

    Args:
        files (List[UploadFile]): A list of image files to generate embeddings for.

    Returns:
        dict: A JSON object containing embeddings for each image.
    """
    images = []
    filenames = []
    for file in files:
        contents = await file.read()
        image = _open_image(io.BytesIO(contents))
        if not is_nsfw_safe(image):
            return {"nsfw": "unsafe"}
        images.append(image)
        filenames.append(file.filename)

    # Generate embeddings in batch
    with torch.no_grad():
        embeddings_tensor = embedding_model.embed_images(images)

    embeddings = []
    for idx in range(len(images)):
        embedding_list = embeddings_tensor[idx].cpu().numpy().tolist()
        embeddings.append({"filename": filenames[idx], "embedding": embedding_list})
    return {"nsfw": "safe", "embeddings": embeddings}


@app.post("/image/nsfw")
async def nsfw_check_endpoint(
    file: UploadFile = File(..., description="Image file to check nsfw")
):
    contents = await file.read()
    image = _open_image(io.BytesIO(contents))
    if not is_nsfw_safe(image):
        return {"nsfw": "unsafe"}
    return {"nsfw": "safe"}
