from pydantic import BaseModel, EmailStr
from datetime import date, datetime
from typing import Optional


class UserBase(BaseModel):
    email: Optional[EmailStr]=None
    name: str
    surname: str
    birthdate: date
    phone: Optional[str] = None
    country: Optional[str] = None
    profile_image: Optional[str] = None
    is_active: Optional[bool] = True

class UserCreate(BaseModel):
    email: str
    name: str
    surname: str
    birthdate: date
    phone: str
    country: str
    profile_image: str
    is_active: bool
    password: str
    created_at: Optional[date] = None

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    name: Optional[str] = None
    surname: Optional[str] = None
    birthdate: Optional[date] = None
    phone: Optional[str] = None
    country: Optional[str] = None
    profile_image: Optional[str] = None
    is_active: Optional[bool] = None


class UserOut(UserBase):
    id: int
    created_at: Optional[date]  # ✅ null olabilir

    class Config:
        orm_mode = True

    profile_image: Optional[str] = None


class PhoneRegister(BaseModel):
    name: str
    surname: str
    birthdate: date
    phone: str
    password: str
