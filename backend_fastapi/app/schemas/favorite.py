from pydantic import BaseModel
from typing import Optional

class FavoriteBase(BaseModel):
    user_id: int

class FavoriteCreate(FavoriteBase):
    pass

class Favorite(FavoriteBase):
    id: int

    class Config:
        from_attributes = True 