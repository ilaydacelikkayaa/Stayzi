from sqlalchemy.orm import Session
from app.models.listing_availability import ListingAvailability
from app.schemas.availability import AvailabilityCreate
from typing import List
from datetime import date

def create_availability(db: Session, data: AvailabilityCreate) -> ListingAvailability:
    obj = ListingAvailability(**data.dict())
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

def filter_availability(
    db: Session,
    start_date: date,
    end_date: date,
    guests: int,
    children: int,
    infants: int,
    pets: int
) -> List[ListingAvailability]:
    return db.query(ListingAvailability).filter(
        ListingAvailability.start_date <= start_date,
        ListingAvailability.end_date >= end_date,
        ListingAvailability.max_guests >= guests,
        ListingAvailability.max_children >= children,
        ListingAvailability.max_infants >= infants,
        ListingAvailability.pets_allowed >= pets
    ).all()
