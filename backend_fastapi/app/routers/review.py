from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
import pika
import json
from datetime import date
from app.db.session import get_db
from app.schemas.review import ReviewCreate, ReviewOut
from app.crud import review as crud_review
from app.dependencies import get_current_user
from app.models.user import User
from app.models.review import Review

router = APIRouter(prefix="/reviews", tags=["Reviews"])

def send_notification(message_type: str, user_id: int, listing_id: int, message: str):
    """RabbitMQ'ya notification mesajı gönderir"""
    try:
        # RabbitMQ bağlantısı
        connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
        channel = connection.channel()
        
        # Queue'yu tanımla
        queue_name = 'notification_queue'
        channel.queue_declare(queue=queue_name, durable=True)
        
        # Mesajı hazırla
        notification_data = {
            "type": message_type,
            "user_id": user_id,
            "listing_id": listing_id,
            "message": message,
            "timestamp": date.today().isoformat()
        }
        
        # Mesajı gönder
        channel.basic_publish(
            exchange='',
            routing_key=queue_name,
            body=json.dumps(notification_data, ensure_ascii=False),
            properties=pika.BasicProperties(
                delivery_mode=2,  # Kalıcı mesaj
            )
        )
        
        print(f"📤 Notification gönderildi: {message_type} - {message}")
        
        connection.close()
        
    except Exception as e:
        print(f"❌ Notification gönderme hatası: {e}")

# ✅ 1. Yeni yorum oluştur
@router.post("/", response_model=ReviewOut)
def create_review(
    review: ReviewCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Yorum oluştur
    new_review = crud_review.create_review(db, user_id=current_user.id, review=review)
    
    # Notification gönder (ev sahibine)
    send_notification(
        message_type="new_review",
        user_id=current_user.id,  # Yorum yapan kullanıcı
        listing_id=review.listing_id,
        message=f"İlanınıza yeni bir yorum geldi! Puan: {review.rating}/5"
    )
    
    return new_review

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
