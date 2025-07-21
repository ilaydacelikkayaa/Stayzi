from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.crud.user import get_user_by_email, get_user_by_phone
from app.models.user import User
import os
from dotenv import load_dotenv

load_dotenv()
SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"

# 👇 Giriş endpoint'in doğruysa bu olmalı
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login/email")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    print("🔑 Gelen Token:", token)

    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    # 🔍 Email veya telefon kontrolü
    if "@" in username:
        print(f">>> Çözülmüş email: {username}")
        user = get_user_by_email(db, username)
    else:
        print(f">>> Çözülmüş phone: {username}")
        user = get_user_by_phone(db, username)

    if user is None:
        print(">>> Kullanıcı objesi: None")
        raise credentials_exception

    if not user.is_active:
        raise HTTPException(status_code=403, detail="Kullanıcı hesabı devre dışı bırakılmış.")

    return user
