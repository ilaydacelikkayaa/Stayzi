from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.crud.user import get_user_by_email, get_user_by_phone
from app.models.user import User
import os

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"

# 👇 Giriş endpoint'in doğruysa bu olmalı
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/login/email")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")  # e-posta veya telefon olabilir
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    # hem e-mail hem telefonla kayıt yapan kullanıcılar olabilir
    user = get_user_by_email(db, username) or get_user_by_phone(db, username)
    if user is None:
        raise credentials_exception

    # ⛔ DEVRE DIŞI kontrolü burada!
    if not user.is_active:
        raise HTTPException(status_code=403, detail="Kullanıcı hesabı devre dışı bırakılmış.")

    return user
