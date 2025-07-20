import os
from dotenv import load_dotenv

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.crud.user import get_user_by_email, get_user_by_phone
from app.models.user import User
from app.utils.redis_client import JWTBlacklist

load_dotenv()  # ✅ .env dosyasını yükle


SECRET_KEY = os.getenv("SECRET_KEY", "your-super-secret-key-here-make-it-long-and-random")
print(">>> SECRET_KEY:", SECRET_KEY)
ALGORITHM = "HS256"

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")  # ✅ düzeltildi
oauth2_scheme_optional = OAuth2PasswordBearer(tokenUrl="/auth/login", auto_error=False)  # Optional için

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Giriş yapmanız gerekiyor",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        print(">>> Token geldi mi:", token)  # ✅ 1. Gelen token'ı yazdır
        
        # JWT token'ın kara listede olup olmadığını kontrol et
        try:
            is_blacklisted = await JWTBlacklist.is_blacklisted(token)
            if is_blacklisted:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Token has been revoked",
                    headers={"WWW-Authenticate": "Bearer"},
                )
        except Exception as e:
            print(f">>> Redis blacklist check error: {e}")
            # Redis hatası durumunda devam et (güvenlik için)
            pass
        
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        phone: str = payload.get("sub")
        print(">>> Çözülmüş phone:", phone)  # ✅ 2. JWT'den çözülen phone'u yazdır
        if phone is None:
            raise credentials_exception
    except JWTError as e:
        print(">>> JWT Hatası:", str(e))  # ✅ 3. Hata varsa konsola yaz
        raise credentials_exception

    user = get_user_by_phone(db, phone=phone)
    print(">>> Kullanıcı objesi:", user)  # ✅ 4. Kullanıcıyı yazdır

    if user is None:
        raise credentials_exception
    return user

async def get_current_user_optional(token: str = Depends(oauth2_scheme_optional), db: Session = Depends(get_db)) -> User | None:
    if token is None:
        return None
        
    try:
        print(">>> Token geldi mi:", token)  # ✅ 1. Gelen token'ı yazdır
        
        # JWT token'ın kara listede olup olmadığını kontrol et
        try:
            is_blacklisted = await JWTBlacklist.is_blacklisted(token)
            if is_blacklisted:
                return None
        except Exception as e:
            print(f">>> Redis blacklist check error: {e}")
            # Redis hatası durumunda devam et (güvenlik için)
            pass
        
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        phone: str = payload.get("sub")
        print(">>> Çözülmüş phone:", phone)  # ✅ 2. JWT'den çözülen phone'u yazdır
        if phone is None:
            return None
    except JWTError as e:
        print(">>> JWT Hatası:", str(e))  # ✅ 3. Hata varsa konsola yaz
        return None

    user = get_user_by_phone(db, phone=phone)
    print(">>> Kullanıcı objesi:", user)  # ✅ 4. Kullanıcıyı yazdır

    if user is None:
        return None
    return user
