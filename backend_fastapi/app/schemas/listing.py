from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

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
    amenities: Optional[List[str]] = None

class ListingCreate(ListingBase):
    pass

class Listing(ListingBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True 