from sqlalchemy.orm import Session
from app.models.listing import Listing
from app.schemas.listing import ListingCreate


def create_listing(db: Session, listing: ListingCreate):
    db_listing = Listing(**listing.model_dump())
    db.add(db_listing)
    db.commit()
    db.refresh(db_listing)
    return db_listing


def get_listing(db: Session, listing_id: int):
    return db.query(Listing).filter(Listing.id == listing_id).first()


def get_listings(db: Session, skip: int = 0, limit: int = 100):
    return db.query(Listing).offset(skip).limit(limit).all()


def delete_listing(db: Session, listing_id: int):
    db_listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if db_listing:
        db.delete(db_listing)
        db.commit()
    return db_listing


def update_listing(db: Session, listing_id: int, listing: ListingCreate):
    db_listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if db_listing:
        for key, value in listing.dict(exclude_unset=True).items():
            setattr(db_listing, key, value)
        db.commit()
        db.refresh(db_listing)
    return db_listing 