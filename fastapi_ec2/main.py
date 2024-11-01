import os
import uvicorn
from fastapi import FastAPI, Request
from fastapi import FastAPI, UploadFile, File, Form, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.openapi.utils import get_openapi
from router.image_router import image_router
from router.treasure_router import treasure_router
from swagger.fix.swagger_monkeypatch import apply_swaggerfix

import logging

# logging.basicConfig(level=logging.DEBUG)

apply_swaggerfix()

app = FastAPI()

app.include_router(treasure_router, prefix="/fastapi_ec2/treasure")
app.include_router(image_router, prefix="/fastapi_ec2/image")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=7999)
