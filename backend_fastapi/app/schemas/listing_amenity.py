from pydantic import BaseModel

class ListingAmenityCreate(BaseModel):
    listing_id: int
    amenity_id: int

