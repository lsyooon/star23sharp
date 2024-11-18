from pydantic import BaseModel, ConfigDict


class BaseDTO(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    @classmethod
    def get_dto(cls, orm):
        return cls.model_validate(orm)
