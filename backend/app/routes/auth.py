from __future__ import annotations

from pydantic import BaseModel, Field, field_validator
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.orm_models import User
from app.services.auth import create_access_token, get_current_user, hash_password, verify_password

router = APIRouter(prefix='/auth', tags=['auth'])


class RegisterRequest(BaseModel):
    email: str = Field(..., min_length=5, max_length=255)
    username: str = Field(..., min_length=2, max_length=120)
    password: str = Field(..., min_length=8, max_length=128)

    @field_validator('email')
    @classmethod
    def valid_email(cls, value: str) -> str:
        cleaned = value.lower().strip()
        if '@' not in cleaned or '.' not in cleaned.split('@')[-1]:
            raise ValueError('Enter a valid email address.')
        return cleaned


class LoginRequest(BaseModel):
    identifier: str = Field(..., min_length=2, max_length=255)
    password: str = Field(..., min_length=1, max_length=128)


def _user_json(user: User) -> dict:
    return {
        'id': user.id,
        'email': user.email,
        'username': user.username,
        'createdAt': user.created_at.isoformat() if user.created_at else None,
    }


@router.post('/register')
async def register(req: RegisterRequest, db: Session = Depends(get_db)):
    email = req.email.lower().strip()
    username = req.username.strip()
    existing = db.query(User).filter(or_(User.email == email, User.username == username)).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail='An account with this email or username already exists.',
        )
    user = User(email=email, username=username, password_hash=hash_password(req.password))
    db.add(user)
    db.commit()
    db.refresh(user)
    return {
        'accessToken': create_access_token(user),
        'tokenType': 'bearer',
        'user': _user_json(user),
    }


@router.post('/login')
async def login(req: LoginRequest, db: Session = Depends(get_db)):
    ident = req.identifier.lower().strip()
    user = db.query(User).filter(
        or_(User.email == ident, User.username == req.identifier.strip())
    ).first()
    if user is None or not verify_password(req.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail='Invalid username/email or password.',
        )
    return {
        'accessToken': create_access_token(user),
        'tokenType': 'bearer',
        'user': _user_json(user),
    }


@router.get('/me')
async def me(user: User = Depends(get_current_user)):
    return {'user': _user_json(user)}
