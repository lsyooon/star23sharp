# Author: DonJun Lee(djleeasi@gmail.com) 2024/10/16
# pytorch implementation of Loss for Label-Aware Contrastive Learning with the Hard Negative Mining
# original paper: Jijun Long et al., CLCE: An Approach to Refining Cross-Entropy and Contrastive Learning for Optimized Learning Fusion (2024)

from typing import Optional

# Based on PyTorch 2.4.1
import torch
from torch import Tensor


class LACNLoss:
    def __init__(
        self,
        temperature: float = 0.5,
        reduce: Optional[bool] = True,
        reduction: str = "mean",
    ):
        self.temperature = temperature
        self.reduce = reduce
        self.reduction = reduction

    def __call__(self, input: Tensor, labels: Tensor) -> Tensor:
        result = self.lacl_loss(input, labels, self.temperature)
        if not self.reduce:
            return result
        if self.reduction == "mean":
            return result.mean()
        elif self.reduction == "sum":
            return result.sum()
        else:
            raise ValueError(
                f"Invalid reduction type: {self.reduction}. Expected 'mean' or 'sum'."
            )

    @staticmethod
    def lacl_loss(
        input: Tensor,
        labels: Tensor,
        temperature: float,
    ) -> Tensor:
        """
        Unsupervised 에는 사용될 수 없음.
        Args:
            input (Tensor): Dimension: 2D (batch_size, embedding_size)
            labels (Tensor): Dimension: 1D (batch_size). 각 vector가 해당되는 class index. Negative sample mining을 하기 위해 사용됨
            temperature (float):
        """
        similarity_matrix = torch.matmul(
            input, input.T
        )  # Normalization이 없기 때문에 input embedding의 mean이 0 이상일 경우 값이 매우 클 수 있다.
        exp_matrix = torch.exp(similarity_matrix / temperature)
        exp_matrix.fill_diagonal_(0)
        exp_square = exp_matrix**2
        same_label_matrix = labels.unsqueeze(0) == labels.unsqueeze(
            1
        )  # 자신과 같은 label의 vector를 filtering 함

        positive_exp_sum = (same_label_matrix.float() * exp_matrix).sum(dim=1)
        negative_exp_sum = exp_matrix.sum(dim=1) - positive_exp_sum

        positive_cardinality = same_label_matrix.sum(dim=1) - 1  # 자신 제외
        negative_cardinality = len(input) - 1 - positive_cardinality  # 역시 자신 제외

        scaling_factor = (negative_cardinality / (negative_exp_sum + 1e-9)).unsqueeze(1)
        weighted_exp_square = (
            scaling_factor * exp_square
        )  # Shapes: (batch_size, 1) * (batch_size, batch_size)
        denominator = positive_exp_sum + weighted_exp_square.sum(dim=1)
        denominator = (
            positive_cardinality * denominator
        )  # batch 안에 자신과 같은 label인 vector가 존재하지 않는 anchor의 경우 0이 발생할 수 있다.

        result = -torch.log((positive_exp_sum + 1e-9) / (denominator + 1e-9))
        # batch 안에 자신과 같은 label인 vector가 존재하지 않는 경우 0이 발생할 수 있는 문제를 inf 값을 0으로 대치함으로써 해결. 이 경우, Loss 를 계산하지 않음.
        result = torch.where(
            torch.isinf(result) | torch.isnan(result),
            torch.tensor(0.0, device=result.device),
            result,
        )  # final result before reduction
        return result
