# To Resolve Known FastAPI with Swagger Issue: https://github.com/fastapi/fastapi/discussions/8741:
# Swagger UI 에서 Array 형식을 Form Data에 넣어서 보내려 할 경우 각 원소를 따로따로 보내는 것이 아니라 한 String으로 합쳐서 보낸다. 이것을 해결할 수 있게 Swagger UI 를 수정하는 fix.
from typing import Any, Dict, Literal, Optional, Type, Union

from fastapi._compat import (
    GenerateJsonSchema,
    JsonSchemaValue,
    ModelField,
    ModelNameMap,
)
from fastapi.openapi.constants import REF_PREFIX
from fastapi.openapi.utils import get_openapi
from pydantic import BaseModel
from pydantic.fields import FieldInfo

# Store the original function, IN GLOBAL
ORIG_GET_REQUEST_BODY = get_openapi.__globals__["get_openapi_operation_request_body"]


def _get_request_body_with_explode(
    *,
    body_field: ModelField | None,
    schema_generator: GenerateJsonSchema,
    model_name_map: ModelNameMap,
    field_mapping: dict[
        tuple[ModelField, Literal["validation", "serialization"]], JsonSchemaValue
    ],
    separate_input_output_schemas: bool = True,
) -> dict[str, Any] | None:
    original = ORIG_GET_REQUEST_BODY(
        body_field=body_field,
        schema_generator=schema_generator,
        model_name_map=model_name_map,
        field_mapping=field_mapping,
        separate_input_output_schemas=separate_input_output_schemas,
    )
    if not original:
        return original
    content = original.get("content", {})
    if form_patch := (
        content.get("application/x-www-form-urlencoded")
        or content.get("multipart/form-data")
    ):
        array_props = []
        schema = body_field._type_adapter.json_schema()
        for prop, prop_schema in schema.get("properties", {}).items():
            if prop_schema.get("anyOf"):
                for union_item in prop_schema.get("anyOf"):
                    if union_item.get("type") == "array":
                        array_props.append(prop)
                        break
            elif prop_schema.get("type") == "array":
                array_props.append(prop)
        form_patch["encoding"] = {prop: {"style": "form"} for prop in array_props}
    return original


def apply_swaggerfix():
    # Apply the monkeypatch, REPLACING the ORIGINAL FUNCTION
    get_openapi.__globals__["get_openapi_operation_request_body"] = (
        _get_request_body_with_explode
    )
