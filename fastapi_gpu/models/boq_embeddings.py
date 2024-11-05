# using models from https://github.com/amaralibey/Bag-of-Queries
from enum import Enum
from typing import List

import torch
import torchvision.transforms as T
from torch import Tensor

from .trained_boq import get_trained_boq


class _BackboneName(Enum):
    RESNET = "resnet50"
    DINOV2 = "dinov2"


_MODEL_INFO = {
    _BackboneName.RESNET: (16384, 384),  # output_dim, expected size of input image
    _BackboneName.DINOV2: (12288, 322),
}


class BOQEmbeddings:
    """
    장소 Embedding을 제공하는 모델
    """

    def __init__(
        self,
        device: torch.device = torch.device(
            "cuda" if torch.cuda.is_available() else "cpu"
        ),
        chunk_size: int = 128,
        backbonename: _BackboneName = _BackboneName.DINOV2,
    ):
        """
        생성자.
        Args:
            device (Union[str, torch.device], optional): The device to run the model on.
                If None, it will use CUDA if available, else CPU. Defaults to None.
            chunk_size (int, optional): 한번에 처리할 batch 크기. 메모리 상황에 따라 유동적으로 조절.
        """
        self.device = torch.device(device)

        self.model = self._load_vpr_model(backbonename)
        self.model = self.model.to(self.device)
        self.model.eval()
        self.chunk_size = chunk_size
        self.transform = self._get_transform(_MODEL_INFO[backbonename][1])

    @staticmethod
    def _get_transform(image_size):
        return T.Compose(
            [
                T.ToTensor(),
                T.Resize(
                    (image_size, image_size),
                    interpolation=T.InterpolationMode.BICUBIC,
                    antialias=True,
                ),
                T.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
            ]
        )

    def _load_vpr_model(self, backbone_name: _BackboneName):
        if not isinstance(backbone_name, _BackboneName):
            raise ValueError(
                "Invalid backbone name! Must be either 'resnet50' or 'dinov2'."
            )

        vpr_model = get_trained_boq(
            backbone_name=backbone_name.value,
            output_dim=_MODEL_INFO[backbone_name][0],
            map_location=self.device,
        )

        return vpr_model

    def embed_chunk(self, img_tensor: Tensor) -> Tensor:
        with torch.no_grad():
            result, _ = self.model(img_tensor)  # discard attention output
        return result

    def embed_tensors(self, img_tensor: Tensor) -> Tensor:
        """
        expects NCHW format tensor
        """
        embeddings = []
        for i in range(0, len(img_tensor), self.chunk_size):
            chunk = img_tensor[i : i + self.chunk_size]
            chunk_embeddings = self.embed_chunk(chunk)
            embeddings.extend(chunk_embeddings)

            # if self.device.type == 'cuda':
            #     torch.cuda.empty_cache()

        return torch.stack(embeddings)

    def embed_tensor(self, img_tensor_single: Tensor) -> Tensor:
        return self.embed_tensors(img_tensor_single.unsqueeze(0)).squeeze(0)

    def embed_image(self, img) -> Tensor:
        return self.embed_tensor(self.transform(img).to(self.device))  # CHW

    def embed_images(self, imgs) -> Tensor:
        tensor_list = []
        for img in imgs:
            tensor_list.append(self.transform(img))
        return self.embed_tensors(torch.stack(tensor_list).to(self.device))
