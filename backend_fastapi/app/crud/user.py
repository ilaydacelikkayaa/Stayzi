from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate
from app.utils.security import hash_password
from app.schemas.user import PhoneRegister
from datetime import datetime, date
import uuid

# 🔍 Tüm kullanıcıları getir (admin için kullanılabilir)
def get_users(db: Session):
    return db.query(User).all()

# 🔍 ID ile kullanıcı getir
def get_user(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()

# 🔍 Email ile kullanıcı getir
def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

# 🔍 Telefon ile kullanıcı getir
def get_user_by_phone(db: Session, phone: str):
    return db.query(User).filter(User.phone == phone).first()

# ✅ Yeni kullanıcı oluştur (şifreyi hashleyerek)
def create_user(db: Session, user: UserCreate):
    hashed_pw = hash_password(user.password)
    db_user = User(
        email=user.email,
        password_hash=hashed_pw,
        name=user.name,
        surname=user.surname,
        birthdate=user.birthdate,
        phone=user.phone,
        country=user.country,
        profile_image=user.profile_image,
        is_active=user.is_active,
        created_at=user.created_at or date.today()
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

# 🗑️ Kullanıcı sil (ID ile)
def delete_user(db: Session, user_id: int):
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        return None
    db.delete(user)
    db.commit()
    return user

# ✏️ Kullanıcıyı ID ile güncelle
def update_user(db: Session, user_id: int, user_data: UserUpdate):
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        return None
    for key, value in user_data.dict(exclude_unset=True).items():
        setattr(user, key, value)
    db.commit()
    db.refresh(user)
    return user

# ✏️ Giriş yapan kullanıcıya göre güncelle (token ile)
def update_user_by_current_user(db: Session, current_user: User, user_data: UserUpdate):
    for key, value in user_data.dict(exclude_unset=True).items():
        setattr(current_user, key, value)
    db.commit()
    db.refresh(current_user)
    return current_user

def create_user_from_phone(db: Session, user: PhoneRegister):
    hashed_pw = hash_password(user.password)
    db_user = User(
        email=None,
        name=user.name,
        surname=user.surname,
        birthdate=user.birthdate,
        phone=user.phone,
        password_hash=hashed_pw,
        country=user.country,  # ✨ bunu ekle
        is_active=True,
        created_at=datetime.utcnow().date()
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user
def get_user_by_phone(db: Session, phone: str):
    return db.query(User).filter(User.phone == phone).first()

def get_user_by_id(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()