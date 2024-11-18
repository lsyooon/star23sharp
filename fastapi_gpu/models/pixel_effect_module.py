# originated from https://github.com/Jzou44/photo2pixel/blob/main/models/module_pixel_effect.py
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision.transforms as T
from PIL import Image
from torch import Tensor


class PixelEffectModule(nn.Module):
    def __init__(
        self,
        device: torch.device = torch.device(
            "cuda" if torch.cuda.is_available() else "cpu"
        ),
    ):
        super(PixelEffectModule, self).__init__()
        self.device = device
        self.transform = T.ToTensor()

    def create_mask_by_idx(self, idx_z, max_z):
        """
        :param idx_z: [H, W]
        :return:
        """
        h, w = idx_z.shape
        idx_x = torch.arange(h).view([h, 1]).repeat([1, w]).to(self.device)
        idx_y = torch.arange(w).view([1, w]).repeat([h, 1]).to(self.device)
        mask = torch.zeros([h, w, max_z]).to(self.device)
        mask[idx_x, idx_y, idx_z] = 1
        return mask

    def select_by_idx(self, data, idx_z):
        """
        :param data: [h,w,C]
        :param idx_z: [h,w]
        :return:
        """
        h, w = idx_z.shape
        idx_x = torch.arange(h).view([h, 1]).repeat([1, w]).to(self.device)
        idx_y = torch.arange(w).view([1, w]).repeat([h, 1]).to(self.device)
        return data[idx_x, idx_y, idx_z]

    def forward(
        self, rgb: Tensor, param_num_bins=4, param_kernel_size=3, param_pixel_size=32
    ) -> Tensor:
        """
        매 입력에 대해 새 Module을 만드는 만큼 그렇게 효율적인 코드는 아닌 것으로 생각된다.
        :param rgb:[b(1), c(3), H, W]
        :return: [b(1), c(3), H, W]
        """
        rgb = rgb.to(self.device)
        r, g, b = rgb[:, 0:1, :, :], rgb[:, 1:2, :, :], rgb[:, 2:3, :, :]

        intensity_idx = torch.mean(rgb, dim=[0, 1]) / 256.0 * param_num_bins
        intensity_idx = intensity_idx.long()

        intensity = self.create_mask_by_idx(intensity_idx, max_z=param_num_bins).to(
            self.device
        )
        intensity = torch.permute(intensity, dims=[2, 0, 1]).unsqueeze(dim=0)

        r, g, b = r * intensity, g * intensity, b * intensity

        kernel_conv = torch.ones(
            [param_num_bins, 1, param_kernel_size, param_kernel_size]
        ).to(self.device)
        r = F.conv2d(
            input=r,
            weight=kernel_conv,
            padding=(param_kernel_size - 1) // 2,
            stride=param_pixel_size,
            groups=param_num_bins,
            bias=None,
        )[0, :, :, :].to(self.device)
        g = F.conv2d(
            input=g,
            weight=kernel_conv,
            padding=(param_kernel_size - 1) // 2,
            stride=param_pixel_size,
            groups=param_num_bins,
            bias=None,
        )[0, :, :, :].to(self.device)
        b = F.conv2d(
            input=b,
            weight=kernel_conv,
            padding=(param_kernel_size - 1) // 2,
            stride=param_pixel_size,
            groups=param_num_bins,
            bias=None,
        )[0, :, :, :].to(self.device)
        intensity = F.conv2d(
            input=intensity,
            weight=kernel_conv,
            padding=(param_kernel_size - 1) // 2,
            stride=param_pixel_size,
            groups=param_num_bins,
            bias=None,
        )[0, :, :, :].to(self.device)
        intensity_max, intensity_argmax = torch.max(intensity, dim=0)

        r = torch.permute(r, dims=[1, 2, 0])
        g = torch.permute(g, dims=[1, 2, 0])
        b = torch.permute(b, dims=[1, 2, 0])

        r = self.select_by_idx(r, intensity_argmax)
        g = self.select_by_idx(g, intensity_argmax)
        b = self.select_by_idx(b, intensity_argmax)

        r = r / intensity_max
        g = g / intensity_max
        b = b / intensity_max

        result_rgb = torch.stack([r, g, b], dim=-1)
        result_rgb = torch.permute(result_rgb, dims=[2, 0, 1]).unsqueeze(dim=0)
        result_rgb = F.interpolate(result_rgb, scale_factor=param_pixel_size)

        return result_rgb

    def filter_img(self, img, *args, **kwargs) -> Tensor:
        imgs = [img]
        return self.filter_imgs(imgs, *args, **kwargs).squeeze(0)

    def filter_imgs(self, imgs, *args, **kwargs) -> Tensor:
        tensor_list = []
        for img in imgs:
            tensor_list.append(self.transform(img))
        return self.forward(torch.stack(tensor_list).to(self.device), *args, **kwargs)
