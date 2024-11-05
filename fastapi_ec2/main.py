import uvicorn
from fastapi import FastAPI, HTTPException
from router.image_router import image_router
from router.treasure_router import treasure_router
from swagger.fix.swagger_monkeypatch import apply_swaggerfix

from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from response.response_model import ResponseModel

import logging

# logging.basicConfig(level=logging.DEBUG)

apply_swaggerfix()

app = FastAPI()


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
    return JSONResponse(
        status_code=422,
        content=ResponseModel(code="E0001", data={"error": str(exc.args)}).model_dump(),
    )


@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request, exc: HTTPException):
    response_model: ResponseModel = exc.detail
    return JSONResponse(
        status_code=exc.status_code,
        content=response_model.model_dump(),
        headers=exc.headers,
    )


app.include_router(treasure_router, prefix="/fastapi_ec2/treasure")
app.include_router(image_router, prefix="/fastapi_ec2/image")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
