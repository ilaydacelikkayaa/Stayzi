from pydantic import BaseModel
from datetime import date, datetime

from typing import Optional

from app.schemas.listing import ListingOut


class BookingBase(BaseModel):
    #user_id: int
    listing_id: int
    start_date: date
    end_date: date
    guests: int
    total_price: float

class BookingCreate(BaseModel):
    listing_id: int
    start_date: date
    end_date: date
    guests: int
    #total_price: float
    
class BookingOut(BookingBase):
    id: int
    listing_id: int
    start_date: date
    end_date: date
    guests: int
    total_price: float
    created_at: datetime
    listing: Optional[ListingOut] = None

    class Config:
        orm_mode = True

from typing import Optional

class BookingUpdate(BaseModel):
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    guests: Optional[int] = None
    #total_price: Optional[float] = None
