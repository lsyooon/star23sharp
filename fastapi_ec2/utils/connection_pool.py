import os

from sqlalchemy import create_engine
from sqlalchemy.orm import Session

DB_PROTOCOL = os.environ["DB_PROTOCOL"]
DB_USERNAME = os.environ["DB_USERNAME"]
DB_PASSWORD = os.environ["DB_PASSWORD"]
DB_DOMAIN = os.environ["DB_DOMAIN"]
DB_PORT = int(os.environ["DB_PORT"])
DB_DBNAME = os.environ["DB_DBNAME"]

EngineGlobal = create_engine(
    f"{DB_PROTOCOL}://{DB_USERNAME}:{DB_PASSWORD}@{DB_DOMAIN}:{DB_PORT}/{DB_DBNAME}"
)


def get_db():
    """데이터베이스 세션을 생성하는 의존성 함수"""
    with Session(EngineGlobal) as session:
        yield session
