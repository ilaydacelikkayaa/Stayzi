from sqlalchemy.orm import Session
from app.models.listing import Listing
from app.schemas.listing import ListingCreate
from app.models.amenity import Amenity


# app/crud/listing.py

def create_listing(db: Session, listing: ListingCreate, user_id: int):
    data = listing.dict(exclude_unset=True)
    data.pop('review_count', None)
    
    # Boolean değerleri integer'a çevir
    for key in ['allow_events', 'allow_smoking', 'allow_commercial_photo']:
        if key in data and isinstance(data[key], bool):
            data[key] = 1 if data[key] else 0
    
    # Handle amenities if they exist
    amenities = None
    if hasattr(listing, 'amenities') and listing.amenities:
        amenity_ids = [a.id for a in listing.amenities]
        amenities = db.query(Amenity).filter(Amenity.id.in_(amenity_ids)).all()
        data.pop('amenities', None)  # Remove from data dict since we handle separately
    
    db_listing = Listing(**data, user_id=user_id)
    if amenities:
        db_listing.amenities = amenities
    
    db.add(db_listing)
    db.commit()
    db.refresh(db_listing)
    return db_listing

def get_listing(db: Session, listing_id: int):
    return db.query(Listing).filter(Listing.id == listing_id).first()


def get_listings(db: Session, skip: int = 0, limit: int = 100):
    return db.query(Listing).offset(skip).limit(limit).all()


def get_listings_by_user(db: Session, user_id: int, skip: int = 0, limit: int = 100):
    return db.query(Listing).filter(Listing.user_id == user_id).offset(skip).limit(limit).all()


def delete_listing(db: Session, listing_id: int):
    db_listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if db_listing:
        db.delete(db_listing)
        db.commit()
    return db_listing


def update_listing(db: Session, listing_id: int, listing: ListingCreate):
    db_listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if db_listing:
        data = listing.dict(exclude_unset=True)
        # Boolean değerleri integer'a çevir
        for key in ['allow_events', 'allow_smoking', 'allow_commercial_photo']:
            if key in data and isinstance(data[key], bool):
                old_value = data[key]
                data[key] = 1 if data[key] else 0
                print(f"DEBUG - CRUD Update: {key} = {old_value} -> {data[key]}")
        
        for key, value in data.items():
            setattr(db_listing, key, value)
        db.commit()
        db.refresh(db_listing)
    return db_listing

from app.crud.user import get_user_by_id

def get_listing_with_host(db: Session, listing_id: int):
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if not listing:
        return None

    amenities_names = [a.name for a in listing.amenities] if listing.amenities else []
    user = get_user_by_id(db, listing.user_id)

    return {
        "id": listing.id,
        "title": listing.title,
        "description": listing.description,
        "price": listing.price,
        "location": listing.location,
        "lat": listing.lat,
        "lng": listing.lng,
        "home_type": listing.home_type,
        "host_languages": listing.host_languages,
        "image_urls": listing.image_urls,
        "created_at": listing.created_at,
        "average_rating": listing.average_rating,
        "home_rules": listing.home_rules,
        "capacity": listing.capacity,
        "amenities": amenities_names,
        "host": {
            "id": user.id,
            "name": user.name,
            "surname": user.surname,
            "profile_image": user.profile_image
        } if user else None
    }



