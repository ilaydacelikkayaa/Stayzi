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
    phone: str
    country: str
    profile_image: Optional[str]
    is_active: Optional[bool]
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


class UserOut(BaseModel):
    id: int
    name: str
    surname: str
    email: Optional[str] = None
    phone: Optional[str] = None
    country: Optional[str] = None
    birthdate: Optional[date] = None
    profile_image: Optional[str] = None
    is_active: Optional[bool] = True

    class Config:
        from_attributes = True


class PhoneRegister(BaseModel):
    email: Optional[EmailStr] = None
    name: str
    surname: str
    birthdate: date
    phone: str
    password: str
    country: Optional[str]

class PhoneLogin(BaseModel):
    phone: str
    password: Optional[str] = None # Şifre artık opsiyonel

class EmailLoginRequest(BaseModel):
    username: str
    password: str