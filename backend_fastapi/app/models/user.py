from sqlalchemy import Column, Integer, String, Boolean, Date
from sqlalchemy.orm import relationship
from app.db.session import Base
from datetime import date

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=True)
    password_hash = Column(String, nullable=False)
    name = Column(String, nullable=True)
    surname = Column(String, nullable=True)
    birthdate = Column(Date, nullable=True)
    phone = Column(String, nullable=True)
    country = Column(String, nullable=True)
    profile_image = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(Date, nullable=False, default=date.today)

    # ✅ İlişkiyi buraya alıyoruz
    bookings = relationship("Booking", back_populates="user")
    reviews = relationship("Review", back_populates="user")
