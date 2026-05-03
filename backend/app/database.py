from __future__ import annotations

import logging
import os
from dataclasses import dataclass
from functools import lru_cache
from typing import Any, Generator

from dotenv import load_dotenv
from fastapi import HTTPException, status
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine, URL
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

load_dotenv()

log = logging.getLogger('cropsense.database')


class Base(DeclarativeBase):
    pass


@dataclass(frozen=True)
class DatabaseConfig:
    mode: str
    target: str
    url: str | URL
    connect_args: dict[str, Any]


def _is_production_runtime() -> bool:
    env_name = os.getenv('APP_ENV') or os.getenv('ENVIRONMENT') or ''
    return (
        os.getenv('RENDER', '').lower() == 'true'
        or env_name.lower() in {'production', 'prod'}
    )


def _config_from_database_url() -> DatabaseConfig | None:
    url = (os.getenv('DATABASE_URL') or '').strip()
    if not url:
        return None

    if url.startswith('sqlite:///'):
        target = url.replace('sqlite:///', '', 1)
        mode = 'sqlite'
    elif url.startswith('sqlite://'):
        target = 'sqlite database'
        mode = 'sqlite'
    else:
        mode = url.split(':', 1)[0] if ':' in url else 'database-url'
        target = f'{mode} database from DATABASE_URL'

    return DatabaseConfig(
        mode=mode,
        target=target,
        url=url,
        connect_args={},
    )


def _config_from_cloud_oracle() -> DatabaseConfig | None:
    user = (os.getenv('DB_USER') or '').strip()
    password = os.getenv('DB_PASSWORD') or ''
    dsn = (os.getenv('DB_DSN') or '').strip()
    if not user or not password or not dsn:
        return None

    return DatabaseConfig(
        mode='oracle-cloud',
        target='DB_DSN configured',
        url=URL.create('oracle+oracledb', username=user, password=password),
        connect_args={'dsn': dsn},
    )


def _config_from_legacy_oracle() -> DatabaseConfig | None:
    user = (os.getenv('ORACLE_USER') or '').strip()
    password = os.getenv('ORACLE_PASSWORD') or ''
    host = (os.getenv('ORACLE_HOST') or '').strip()
    service = (
        os.getenv('ORACLE_SERVICE_NAME')
        or os.getenv('ORACLE_SERVICE')
        or ''
    ).strip()
    port_raw = (os.getenv('ORACLE_PORT') or '1521').strip()

    if not user or not password or not host or not service:
        return None

    if _is_production_runtime() and host.lower() in {'localhost', '127.0.0.1'}:
        log.warning(
            'Ignoring legacy Oracle localhost configuration in production. '
            'Set DATABASE_URL or DB_USER/DB_PASSWORD/DB_DSN on Render.'
        )
        return None

    try:
        port = int(port_raw)
    except ValueError:
        port = 1521

    return DatabaseConfig(
        mode='oracle-legacy',
        target=f'{host}:{port}/{service}',
        url=URL.create(
            'oracle+oracledb',
            username=user,
            password=password,
            host=host,
            port=port,
            query={'service_name': service},
        ),
        connect_args={},
    )


@lru_cache(maxsize=1)
def _database_config() -> DatabaseConfig | None:
    return (
        _config_from_database_url()
        or _config_from_cloud_oracle()
        or _config_from_legacy_oracle()
    )


def database_config_summary() -> dict[str, str]:
    config = _database_config()
    if config is None:
        return {'mode': 'not-configured', 'target': 'none'}
    return {'mode': config.mode, 'target': config.target}


def database_url() -> str:
    config = _database_config()
    if config is None:
        return ''
    if isinstance(config.url, URL):
        return config.url.render_as_string(hide_password=True)
    return config.url


@lru_cache(maxsize=1)
def get_engine() -> Engine | None:
    config = _database_config()
    if config is None:
        return None
    return create_engine(
        config.url,
        pool_pre_ping=True,
        future=True,
        connect_args=config.connect_args,
    )


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
