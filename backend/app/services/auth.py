from __future__ import annotations

import base64
import hashlib
import hmac
import json
import os
import secrets
from datetime import datetime, timedelta, timezone
from typing import Any

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.orm_models import User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl='/api/auth/login')


def _secret() -> bytes:
    return (os.getenv('AUTH_SECRET_KEY') or os.getenv('SECRET_KEY') or 'dev-change-me').encode()


def _b64(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).decode().rstrip('=')


def _unb64(data: str) -> bytes:
    return base64.urlsafe_b64decode(data + '=' * (-len(data) % 4))


def hash_password(password: str) -> str:
    salt = secrets.token_bytes(16)
    digest = hashlib.pbkdf2_hmac('sha256', password.encode(), salt, 240_000)
    return f'pbkdf2_sha256${_b64(salt)}${_b64(digest)}'


def verify_password(password: str, stored_hash: str) -> bool:
    try:
        scheme, salt_b64, digest_b64 = stored_hash.split('$', 2)
        if scheme != 'pbkdf2_sha256':
            return False
        salt = _unb64(salt_b64)
        expected = _unb64(digest_b64)
        actual = hashlib.pbkdf2_hmac('sha256', password.encode(), salt, 240_000)
        return hmac.compare_digest(actual, expected)
    except Exception:
        return False


def create_access_token(user: User) -> str:
    now = datetime.now(timezone.utc)
    expires = now + timedelta(minutes=int(os.getenv('ACCESS_TOKEN_EXPIRE_MINUTES', '720')))
    header = {'alg': 'HS256', 'typ': 'JWT'}
    payload: dict[str, Any] = {
        'sub': user.id,
        'email': user.email,
        'username': user.username,
        'iat': int(now.timestamp()),
        'exp': int(expires.timestamp()),
    }
    encoded_header = _b64(json.dumps(header, separators=(',', ':')).encode())
    encoded_payload = _b64(json.dumps(payload, separators=(',', ':')).encode())
    signing_input = f'{encoded_header}.{encoded_payload}'.encode()
    signature = _b64(hmac.new(_secret(), signing_input, hashlib.sha256).digest())
    return f'{encoded_header}.{encoded_payload}.{signature}'


def decode_access_token(token: str) -> dict[str, Any]:
    try:
        header, payload, signature = token.split('.', 2)
        signing_input = f'{header}.{payload}'.encode()
        expected = _b64(hmac.new(_secret(), signing_input, hashlib.sha256).digest())
        if not hmac.compare_digest(signature, expected):
            raise ValueError('bad signature')
        data = json.loads(_unb64(payload))
        if int(data.get('exp', 0)) < int(datetime.now(timezone.utc).timestamp()):
            raise ValueError('expired')
        return data
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail='Invalid or expired session. Please log in again.',
            headers={'WWW-Authenticate': 'Bearer'},
        ) from exc


def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> User:
    data = decode_access_token(token)
    user = db.get(User, data.get('sub'))
    if user is None or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail='User session is no longer valid.',
            headers={'WWW-Authenticate': 'Bearer'},
        )
    return user
