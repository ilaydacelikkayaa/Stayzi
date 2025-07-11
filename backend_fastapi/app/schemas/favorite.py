from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class FavoriteBase(BaseModel):
    listing_id: int
    list_name: Optional[str] = None

class FavoriteCreate(FavoriteBase):
    pass

class Favorite(FavoriteBase):
    id: int
    user_id: int
    created_at: datetime

    class Config:

        from_attributes = True

