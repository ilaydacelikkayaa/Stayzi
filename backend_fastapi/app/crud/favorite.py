from sqlalchemy.orm import Session
from app.models.favorite import Favorite
from app.schemas.favorite import FavoriteCreate
from typing import Optional
from fastapi import HTTPException  # ❗️eklemeyi unutma

# Favori oluştur
def create_favorite(db: Session, favorite: FavoriteCreate, user_id: int):
    # 🔍 Daha önce eklenmiş mi kontrol et
    existing = db.query(Favorite).filter(
        Favorite.user_id == user_id,
        Favorite.listing_id == favorite.listing_id
    ).first()

    if existing:
        raise HTTPException(
            status_code=400,
            detail="Bu ilan zaten favorilere eklenmiş."
        )

    # ✅ Yeni favori oluştur
    db_favorite = Favorite(
        user_id=user_id,
        **favorite.model_dump()
    )
    db.add(db_favorite)
    db.commit()
    db.refresh(db_favorite)
    return db_favorite

# Kullanıcının favorilerini getir (isteğe bağlı list_name filtresiyle)
def get_favorites_by_user(
    db: Session,
    user_id: int,
    list_name: Optional[str] = None,
    skip: int = 0,
    limit: int = 100
):
    query = db.query(Favorite).filter(Favorite.user_id == user_id)
    if list_name:
        query = query.filter(Favorite.list_name == list_name)
    return query.offset(skip).limit(limit).all()

# Favori sil
def delete_favorite(db: Session, favorite_id: int):
    fav = db.query(Favorite).filter(Favorite.id == favorite_id).first()
    if fav:
        db.delete(fav)
        db.commit()
        return True
    return False
