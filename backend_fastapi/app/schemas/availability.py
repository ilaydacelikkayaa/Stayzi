from pydantic import BaseModel
from datetime import date

class AvailabilityCreate(BaseModel):
    listing_id: int
    start_date: date
    end_date: date
    max_guests: int
    max_children: int
    max_infants: int
    pets_allowed: int

class AvailabilityOut(AvailabilityCreate):
    id: int

    class Config:
        orm_mode = True  # Pydantic v2'de from_attributes kullanabilirsin
