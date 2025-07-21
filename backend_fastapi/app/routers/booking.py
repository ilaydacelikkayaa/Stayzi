import logging
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from datetime import date
import pika
import json

from app.db.session import get_db
from app.schemas.booking import BookingCreate, BookingOut, BookingUpdate
from app.crud import booking as crud_booking
from app.dependencies import get_current_user
from app.models.user import User

# 📢 Logger başlat
logger = logging.getLogger(__name__)

router = APIRouter(prefix="/bookings", tags=["Bookings"])

# 📬 RabbitMQ'ya notification gönderme fonksiyonu
def send_notification(message_type: str, user_id: int, listing_id: int, message: str):
    """RabbitMQ'ya notification mesajı gönderir"""
    try:
        connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
        channel = connection.channel()

        queue_name = 'notification_queue'
        channel.queue_declare(queue=queue_name, durable=True)

        notification_data = {
            "type": message_type,
            "user_id": user_id,
            "listing_id": listing_id,
            "message": message,
            "timestamp": date.today().isoformat()
        }

        channel.basic_publish(
            exchange='',
            routing_key=queue_name,
            body=json.dumps(notification_data, ensure_ascii=False),
            properties=pika.BasicProperties(delivery_mode=2)
        )

        logger.info(f"📤 Notification gönderildi: {message_type} - {message}")
        connection.close()

    except Exception as e:
        logger.error(f"❌ RabbitMQ notification gönderme hatası: {e}")

# ✅ 1. Giriş yapan kullanıcının rezervasyonlarını filtreleyerek getir
@router.get("/", response_model=list[BookingOut])
def get_my_bookings_filtered(
    status: str = Query(None, description="active = sadece gelecektekiler"),
    date_from: date = Query(None, description="belirli bir tarihten sonra"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    bookings = crud_booking.get_bookings_by_user(db, current_user.id)

    if status and status.strip() == "active":
        bookings = [b for b in bookings if b.start_date >= date.today()]

    if date_from:
        bookings = [b for b in bookings if b.start_date >= date_from]

    return bookings

# ➕ 2. Yeni rezervasyon oluştur
@router.post("/", response_model=BookingOut)
def create_booking(
    booking: BookingCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    new_booking = crud_booking.create_booking(db, booking, user_id=current_user.id)

    send_notification(
        message_type="booking_confirmation",
        user_id=current_user.id,
        listing_id=booking.listing_id,
        message=f"Rezervasyonunuz onaylandı! {booking.start_date} - {booking.end_date}"
    )

    return new_booking

# 🔍 3. Tek bir rezervasyonu getir
@router.get("/{booking_id}", response_model=BookingOut)
def read_booking(booking_id: int, db: Session = Depends(get_db)):
    db_booking = crud_booking.get_booking(db, booking_id)
    if not db_booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    return db_booking

# 🛠️ 4. Rezervasyonu güncelle
@router.put("/{booking_id}", response_model=BookingOut)
def update_booking_endpoint(
    booking_id: int,
    booking_update: BookingUpdate,
    db: Session = Depends(get_db)
):
    db_booking = crud_booking.update_booking(db, booking_id, booking_update)
    if not db_booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    return db_booking

# ❌ 5. Rezervasyon sil
@router.delete("/{booking_id}", response_model=BookingOut)
def delete_booking(booking_id: int, db: Session = Depends(get_db)):
    db_booking = crud_booking.delete_booking(db, booking_id)
    if not db_booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    return db_booking