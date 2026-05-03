from __future__ import annotations

import os
from functools import lru_cache
from typing import Generator

from dotenv import load_dotenv
from fastapi import HTTPException, status
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

load_dotenv()


class Base(DeclarativeBase):
    pass


def _oracle_url_from_env() -> str:
    user = os.getenv('ORACLE_USER', '')
    password = os.getenv('ORACLE_PASSWORD', '')
    host = os.getenv('ORACLE_HOST', 'localhost')
    port = os.getenv('ORACLE_PORT', '1521')
    service = os.getenv('ORACLE_SERVICE_NAME') or os.getenv('ORACLE_SERVICE', 'XEPDB1')
    if not user or not password:
        return ''
    return f'oracle+oracledb://{user}:{password}@{host}:{port}/?service_name={service}'


def database_url() -> str:
    return os.getenv('DATABASE_URL') or _oracle_url_from_env()


@lru_cache(maxsize=1)
def get_engine() -> Engine | None:
    url = database_url()
    if not url:
        return None
    return create_engine(url, pool_pre_ping=True, future=True)


@lru_cache(maxsize=1)
def get_sessionmaker() -> sessionmaker[Session] | None:
    engine = get_engine()
    if engine is None:
        return None
    return sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)


def init_db() -> bool:
    engine = get_engine()
    if engine is None:
        return False
    import app.models.orm_models  # noqa: F401 - registers tables on Base

    Base.metadata.create_all(bind=engine)
    return True


def get_db() -> Generator[Session, None, None]:
    factory = get_sessionmaker()
    if factory is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=(
                'Database is not configured. Set DATABASE_URL or Oracle '
                'environment variables before using protected farmer data APIs.'
            ),
        )
    db = factory()
    try:
        yield db
    finally:
        db.close()
