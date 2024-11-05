import uvicorn
from fastapi import FastAPI, HTTPException, Request
from router.image_router import image_router
from router.treasure_router import treasure_router
from swagger.fix.swagger_monkeypatch import apply_swaggerfix

from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from response.response_model import ResponseModel
from response.exceptions import AppException, UnhandledException, InvalidInputException

import logging

# logging.basicConfig(level=logging.DEBUG)

apply_swaggerfix()

app = FastAPI()

@app.middleware("http")
async def global_exception_handler(request: Request, call_next):
    try:
        response = await call_next(request)
        return response
    except AppException as app_exc:
        return JSONResponse(
            status_code=app_exc.status_code,
            content=app_exc.to_response_model().model_dump()
        )
    except HTTPException as http_exc:
        json_content = None
        if isinstance(http_exc.detail, dict):
            try:
                json_content = ResponseModel.model_validate(http_exc.detail).model_dump()
            except Exception:
                logging.exception("HTTPException 처리 중 오류 발생.")
        else:
            logging.exception("핸들링 불가능한 HTTPException 발생.")
        
        if json_content is None:
            json_content = ResponseModel(
                code=UnhandledException.code, 
                message="예상하지 못했거나 적절한 응답 형식으로 변환할 수 없는 HTTPException 입니다."
            ).model_dump()
        
        return JSONResponse(
            status_code=http_exc.status_code,
            content=json_content
        )
    except Exception:
        logging.exception(f"예상하지 못한 오류가 {request.url.path}에서 발생했습니다.")
        return JSONResponse(
            status_code=UnhandledException.status_code,
            content=ResponseModel(
                code=UnhandledException.code, 
                message="예상치 못한 오류가 발생하였습니다."
            ).model_dump()
        )



@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
    return JSONResponse(
        status_code=422,
        content=InvalidInputException().to_response_model(data={"error": str(exc.args)}).model_dump()
    )


app.include_router(treasure_router, prefix="/fastapi_ec2/treasure")
app.include_router(image_router, prefix="/fastapi_ec2/image")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
