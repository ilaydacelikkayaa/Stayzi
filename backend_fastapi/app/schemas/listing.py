from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from .user import UserOut

from app.schemas.amenity import Amenity, AmenityInListing


class ListingBase(BaseModel):
   
    title: str
    description: Optional[str] = None
    price: float
    location: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    home_type: Optional[str] = None
    host_languages: Optional[List[str]] = None
    image_urls: Optional[List[str]] = None
    average_rating: Optional[float] = 0
    home_rules: Optional[str] = None
    capacity: Optional[int] = None
    amenities: Optional[List[AmenityInListing]] = None
    room_count: Optional[int] = None
    bed_count: Optional[int] = None
    bathroom_count: Optional[int] = None
    #review_count: Optional[int] = 0
    
    # Yeni izin alanları
    allow_events: Optional[int] = 0  # 0: izin yok, 1: izin var
    allow_smoking: Optional[int] = 0  # 0: izin yok, 1: izin var
    allow_commercial_photo: Optional[int] = 0  # 0: izin yok, 1: izin var
    max_guests: Optional[int] = 1

class ListingCreate(ListingBase):
    pass

class Listing(ListingBase):
    id: int
    created_at: datetime
    user: Optional[UserOut] = None

    class Config:
        from_attributes = True


class ListingOut(BaseModel):
    id: int
    user_id: Optional[int]
    title: str
    description: Optional[str]
    price: float
    location: str
    created_at: datetime
    image_urls: Optional[List[str]]
    average_rating: Optional[float]

    class Config:
        from_attributes = True

class ListingWithHost(ListingBase):
    id: int
    created_at: datetime
    user: Optional[UserOut] = None

    class Config:
        from_attributes = True