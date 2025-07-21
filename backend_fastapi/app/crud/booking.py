from sqlalchemy.orm import Session
from sqlalchemy import and_
from datetime import date
from fastapi import HTTPException

from app.models.booking import Booking
from app.schemas.booking import BookingCreate, BookingUpdate
from app.utils.rabbitmq_client import send_booking_created_message

# ➕ Booking Oluştur
from app.models.listing import Listing  # ⬅️ İlan modelini ekle


# ➕ Booking Oluştur
def create_booking(db: Session, booking: BookingCreate, user_id: int):
    today = date.today()

    # 🎯 Giriş tarihi bugünden önce olamaz
    if booking.start_date < today:
        raise HTTPException(status_code=400, detail="Giriş tarihi bugünden önce olamaz.")

    # 🎯 Bitiş tarihi giriş tarihinden sonra olmalı
    if booking.end_date <= booking.start_date:
        raise HTTPException(status_code=400, detail="Bitiş tarihi, giriş tarihinden sonra olmalıdır.")

    # ❌ Çakışan rezervasyon kontrolü
    overlapping = db.query(Booking).filter(
        Booking.listing_id == booking.listing_id,
        and_(
            Booking.start_date < booking.end_date,
            Booking.end_date > booking.start_date
        )
    ).first()

    if overlapping:
        raise HTTPException(status_code=409, detail="Bu tarih aralığında başka bir rezervasyon mevcut.")

    # 🧮 total_price hesapla
    listing = db.query(Listing).filter(Listing.id == booking.listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="İlan bulunamadı.")

    nights = (booking.end_date - booking.start_date).days
    total_price = nights * listing.price

    # ✅ Yeni rezervasyonu oluştur
    db_booking = Booking(
        user_id=user_id,
        listing_id=booking.listing_id,
        start_date=booking.start_date,
        end_date=booking.end_date,
        guests=booking.guests,
        total_price=total_price  # ⬅️ buraya hesapladığın değeri yaz
    )

    db.add(db_booking)
    db.commit()
    db.refresh(db_booking)

    # 📤 RabbitMQ'ya mesaj gönder
    send_booking_created_message({
        "booking_id": db_booking.id,
        "user_id": db_booking.user_id,
        "listing_id": db_booking.listing_id,
        "start_date": str(db_booking.start_date),
        "end_date": str(db_booking.end_date),
        "created_at": str(db_booking.created_at),
        "total_price": float(db_booking.total_price)
    })

    return db_booking

# 🔍 Belirli bir booking ID'sini getir
def get_booking(db: Session, booking_id: int):
    return db.query(Booking).filter(Booking.id == booking_id).first()

# 📋 Tüm bookingleri getir
def get_all_bookings(db: Session, skip: int = 0, limit: int = 100):
    return db.query(Booking).offset(skip).limit(limit).all()

# ❌ Booking sil
def delete_booking(db: Session, booking_id: int):
    db_booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if db_booking:
        db.delete(db_booking)
        db.commit()
    return db_booking

# 🔄 Booking güncelle (geçerli ise)
def update_booking(db: Session, booking_id: int, update_data: BookingUpdate):
    db_booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not db_booking:
        return None

    # update_data içindeki her alanı güncelle
    for field, value in update_data.dict(exclude_unset=True).items():
        setattr(db_booking, field, value)

    db.commit()
    db.refresh(db_booking)
    return db_booking

# 👤 Kullanıcıya ait rezervasyonları getir
def get_bookings_by_user(db: Session, user_id: int):
    return db.query(Booking).filter(Booking.user_id == user_id).all()

def get_bookings_by_listing(db: Session, listing_id: int):
    return db.query(Booking).filter(Booking.listing_id == listing_id).all()