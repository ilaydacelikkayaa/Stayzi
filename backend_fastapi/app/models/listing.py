from sqlalchemy import Column, Integer, Text, Numeric, ForeignKey, Double, ARRAY, TIMESTAMP
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship  # ⬅️ Bunu da unutma
from app.db.session import Base

class Listing(Base):
    __tablename__ = "listings"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    title = Column(Text, nullable=False)
    description = Column(Text)
    price = Column(Numeric, nullable=False)
    location = Column(Text)
    lat = Column(Double)
    lng = Column(Double)
    home_type = Column(Text)
    host_languages = Column(ARRAY(Text))
    image_urls = Column(ARRAY(Text))
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    average_rating = Column(Numeric, server_default="0")
    home_rules = Column(Text)

    # ✅ İlişki satırı sınıfın içinde olmalı
    bookings = relationship("Booking", back_populates="listing")

