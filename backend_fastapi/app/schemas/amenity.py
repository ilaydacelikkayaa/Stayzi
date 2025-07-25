from typing import Optional

from pydantic import BaseModel

class AmenityBase(BaseModel):
    name: str

class AmenityCreate(AmenityBase):
    pass

class Amenity(AmenityBase):
    id: int

    class Config:
        from_attributes = True  # eski adı orm_mode

class AmenityInListing(BaseModel):
    id: int
    name: Optional[str] = None