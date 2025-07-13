from sqlalchemy import Column, Integer, ForeignKey, Date, Numeric, TIMESTAMP
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.session import Base

class Booking(Base):
    __tablename__ = "bookings"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    listing_id = Column(Integer, ForeignKey("listings.id"))
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    guests = Column(Integer, nullable=False)
    total_price = Column(Numeric, nullable=False)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    # 💥 HATAYI ÇÖZEN KISIM
    user = relationship("User", back_populates="bookings")
    listing = relationship("Listing", back_populates="bookings")
