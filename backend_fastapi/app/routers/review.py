from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.db.session import get_db
from app.schemas.review import ReviewCreate, ReviewOut
from app.crud import review as crud_review
from app.dependencies import get_current_user
from app.models.user import User
from app.models.review import Review


router = APIRouter(prefix="/reviews", tags=["Reviews"])

# ✅ 1. Yeni yorum oluştur
@router.post("/", response_model=ReviewOut)
def create_review(
    review: ReviewCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return crud_review.create_review(db, user_id=current_user.id, review=review)

# ✅ 2. Bir ilana ait yorumları listele
@router.get("/listing/{listing_id}", response_model=List[ReviewOut])
def get_reviews_for_listing(
    listing_id: int,
    db: Session = Depends(get_db)
):
    return crud_review.get_reviews_by_listing(db, listing_id)
from fastapi import HTTPException
from app.schemas.review import ReviewUpdate

@router.put("/{review_id}", response_model=ReviewOut)
def update_review(
    review_id: int,
    review_update: ReviewUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    updated = crud_review.update_review(db, review_id, current_user.id, review_update)
    if not updated:
        raise HTTPException(status_code=404, detail="Yorum bulunamadı veya yetkisiz erişim.")
    return updated
from fastapi import status

@router.delete("/{review_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_review(
    review_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    success = crud_review.delete_review(db, review_id, current_user.id)
    if not success:
        raise HTTPException(status_code=404, detail="Yorum bulunamadı veya silme yetkiniz yok.")
    return
@router.get("/my", response_model=List[ReviewOut])
def get_my_reviews(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return db.query(Review).filter(Review.user_id == current_user.id).all()
@router.get("/search", response_model=List[ReviewOut])
def search_reviews(
    keyword: str,
    db: Session = Depends(get_db)
):
    return db.query(Review).filter(Review.comment.ilike(f"%{keyword}%")).all()
@router.get("/listing/{listing_id}/average-rating")
def get_average_rating(listing_id: int, db: Session = Depends(get_db)):
    from sqlalchemy import func
    avg_rating = db.query(func.avg(Review.rating)).filter(Review.listing_id == listing_id).scalar()
    return {"listing_id": listing_id, "average_rating": round(avg_rating or 0, 2)}
@router.get("/listing/{listing_id}/count")
def get_review_count(listing_id: int, db: Session = Depends(get_db)):
    count = db.query(Review).filter(Review.listing_id == listing_id).count()
    return {"listing_id": listing_id, "review_count": count}
