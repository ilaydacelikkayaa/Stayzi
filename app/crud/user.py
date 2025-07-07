from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserCreate,UserUpdate,UserOut
from app.utils.security import hash_password 

def get_users(db: Session):
    return db.query(User).all()

def get_user(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()

#def create_user(db: Session, user: UserCreate):
 #   db_user = User(**user.dict())
  #  db.add(db_user)
   # db.commit()
    #db.refresh(db_user)
    #return db_user

def delete_user(db: Session, user_id: int):
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        return None
    db.delete(user)
    db.commit()
    return user

def update_user(db: Session, user_id: int, user_data: UserUpdate):
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        return None
    for key, value in user_data.dict(exclude_unset=True).items():
        setattr(user, key, value)
    db.commit()
    db.refresh(user)
    return user

def create_user(db: Session, user: UserCreate):
    hashed_pw = hash_password(user.password_hash)
    db_user = User(
        email=user.email,
        name=user.name,
        surname=user.surname,
        birthdate=user.birthdate,
        phone=user.phone,
        country=user.country,
        profile_image=user.profile_image,
        is_active=user.is_active,
        password_hash=hashed_pw,
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user
def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def get_user_by_phone(db: Session, phone: str):
    return db.query(User).filter(User.phone == phone).first()
def update_user_by_current_user(db: Session, current_user: User, user_data: UserUpdate):
    for key, value in user_data.dict(exclude_unset=True).items():
        setattr(current_user, key, value)
    db.commit()
    db.refresh(current_user)
    return current_user
