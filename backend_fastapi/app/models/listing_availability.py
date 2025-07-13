from sqlalchemy import Column, Integer, Date, ForeignKey
from app.db.session import Base
from sqlalchemy import Boolean




class ListingAvailability(Base):
    __tablename__ = "listing_availability"

    id = Column(Integer, primary_key=True, index=True)
    listing_id = Column(Integer, ForeignKey("listings.id"))
    start_date = Column(Date)
    end_date = Column(Date)
    max_guests = Column(Integer)
    max_children = Column(Integer)  # Yeni eklendi
    max_infants = Column(Integer)   # Yeni eklendi
    pets_allowed = Column(Boolean, nullable=False)