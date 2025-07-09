from sqlalchemy.orm import Session
from app.models.favorite import Favorite
from app.schemas.favorite import FavoriteCreate

def create_favorite(db: Session, favorite: FavoriteCreate):
    db_favorite = Favorite(**favorite.model_dump())
    db.add(db_favorite)
    db.commit()
    db.refresh(db_favorite)
    return db_favorite

def get_favorites_by_user(db: Session, user_id: int, skip: int = 0, limit: int = 100):
    return db.query(Favorite).filter(Favorite.user_id == user_id).offset(skip).limit(limit).all() 