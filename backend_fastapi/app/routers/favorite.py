from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.schemas.favorite import Favorite, FavoriteCreate
from app.crud.favorite import create_favorite, get_favorites_by_user
from app.db.dependency import get_db
from app.dependencies import get_current_user
from app.models.user import User

router = APIRouter(
    prefix="/favorites",
    tags=["favorites"]
)

@router.post("/", response_model=Favorite)
def create(favorite: FavoriteCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return create_favorite(db, favorite)

@router.get("/my-favorites", response_model=List[Favorite])
def read_my_favorites(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return get_favorites_by_user(db, current_user.id, skip=skip, limit=limit) 