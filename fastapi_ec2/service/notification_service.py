import os
from typing import List

import httpx
from pydantic import BaseModel
from response.exceptions import AppException

URL_SPRING = os.environ["URL_SPRING"]


# Request body model
class TreasureHiddenNotificationToReceivers(BaseModel):
    receiverId: int
    messageId: int


class TreasureRevealedNotificationToSender(BaseModel):
    messageId: int


async def treasure_hidden_notification_to_receivers(
    messageId: int, receivers: List[int], token: str
):
    url = URL_SPRING + "/notification/receiver-push"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    for receiver in receivers:
        payload = TreasureHiddenNotificationToReceivers(
            receiverId=receiver, messageId=messageId
        ).model_dump()
        async with httpx.AsyncClient() as client:
            response = await client.post(url, json=payload, headers=headers)
            if response.status_code != 200:
                raise AppException.construct(
                    response.status_code, code=response.json().get("code")
                )


async def treasure_revealed_notification_to_sender(messageId: int, token: str):
    url = URL_SPRING + "/notification/sender-push"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    payload = TreasureHiddenNotificationToReceivers(messageId=messageId).model_dump()
    async with httpx.AsyncClient() as client:
        response = await client.post(url, json=payload, headers=headers)
        if response.status_code != 200:
            raise AppException.construct(
                response.status_code, code=response.json().get("code")
            )
