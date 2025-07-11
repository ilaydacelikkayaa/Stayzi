from pydantic import BaseModel, EmailStr
from datetime import date
from typing import Optional


class UserBase(BaseModel):
    email: Optional[EmailStr] = None
    name: Optional[str] = None
    surname: Optional[str] = None
    birthdate: Optional[date] = None
    phone: Optional[str] = None
    country: Optional[str] = None
    profile_image: Optional[str] = None
    is_active: Optional[bool] = True


class UserCreate(BaseModel):
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    password: str
    name: str
    surname: str
    birthdate: date
    country: Optional[str] = None
    profile_image: Optional[str] = None
    is_active: Optional[bool] = True
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
    created_at: Optional[date]

    class Config:
        orm_mode = True


class PhoneRegister(BaseModel):
    name: str
    surname: str
    birthdate: date
    phone: str
    password: str