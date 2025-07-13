from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from datetime import date
from typing import List

from app.db.session import get_db
from app.schemas.availability import AvailabilityCreate, AvailabilityOut
from app.crud import availability as crud_availability

router = APIRouter(prefix="/availability", tags=["Availability"])

# ✅ 1. Yeni müsaitlik bilgisi oluştur
@router.post("/", response_model=AvailabilityOut)
def create_availability(
    data: AvailabilityCreate,
    db: Session = Depends(get_db)
):
    return crud_availability.create_availability(db, data)


# ✅ 2. Filtreleme: tarih, kişi sayısı, çocuk, bebek, evcil hayvan
@router.get("/search", response_model=List[AvailabilityOut])
def search_available_listings(
    start_date: date,
    end_date: date,
    guests: int,
    children: int,
    infants: int,
    pets: int,
    db: Session = Depends(get_db)
):
    return crud_availability.filter_availability(
        db, start_date, end_date, guests, children, infants, pets
    )
