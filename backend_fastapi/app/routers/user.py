from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.db.session import get_db
from app.schemas.user import UserCreate, UserOut, UserUpdate
from app.crud import user as user_crud
from app.dependencies import get_current_user
from app.models.user import User

router = APIRouter(tags=["Users"])

@router.get("/me", response_model=UserOut)
def get_my_profile(current_user: User = Depends(get_current_user)):
    return current_user

@router.get("/", response_model=List[UserOut])
def list_users(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return user_crud.get_users(db)

@router.get("/{user_id}", response_model=UserOut)
def get_user_by_id(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    user = user_crud.get_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.post("/", response_model=UserOut)
def create_user(
    user: UserCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return user_crud.create_user(db, user)

@router.delete("/{user_id}", response_model=UserOut)
def delete_user_route(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    user = user_crud.delete_user(db, user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.put("/{user_id}", response_model=UserOut)
def update_user_route(
    user_id: int,
    user_data: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    user = user_crud.update_user(db, user_id, user_data)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user
@router.post("/register", response_model=UserOut)
def register_user(user_in: UserCreate, db: Session = Depends(get_db)):
    existing_user = user_crud.get_user_by_email(db, user_in.email)
    if existing_user:
        raise HTTPException(status_code=400, detail="E-posta zaten kayıtlı")

    return user_crud.create_user(db, user_in)

@router.post("/register-phone", response_model=UserOut)
def register_with_phone(user: UserCreate, db: Session = Depends(get_db)):
    if not user.phone:
        raise HTTPException(status_code=400, detail="Telefon numarası gereklidir")

    existing_user = user_crud.get_user_by_phone(db, user.phone)
    if existing_user:
        raise HTTPException(status_code=400, detail="Bu telefon numarasıyla kayıtlı bir kullanıcı var")

    return user_crud.create_user(db, user)


@router.put("/me", response_model=UserOut)
def update_my_profile(
    user_data: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return user_crud.update_user_by_current_user(db, current_user, user_data)

