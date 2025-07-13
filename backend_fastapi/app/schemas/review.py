from pydantic import BaseModel
from datetime import datetime

class ReviewCreate(BaseModel):
    listing_id: int
    rating: float
    comment: str

class ReviewOut(BaseModel):
    id: int
    user_id: int
    listing_id: int
    rating: float
    comment: str
    created_at: datetime

    class Config:
        orm_mode = True
class ReviewUpdate(BaseModel):
    rating: float
    comment: str
