from sqlalchemy.orm import Session
from app.models.listing_amenity import ListingAmenity
from app.schemas.listing_amenity import ListingAmenityCreate
from fastapi import HTTPException
def create_listing_amenity(db: Session, la: ListingAmenityCreate):
    try:
        # ❗️Daha önce eklenmiş mi kontrolü
        existing = db.query(ListingAmenity).filter_by(
            listing_id=la.listing_id,
            amenity_id=la.amenity_id
        ).first()

        if existing:
            raise HTTPException(status_code=400, detail="Bu özellik zaten bu ilana eklenmiş.")

        # Ekleme işlemi
        db_la = ListingAmenity(**la.model_dump())
        db.add(db_la)
        db.commit()
        db.refresh(db_la)
        return db_la

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def get_amenities_for_listing(db: Session, listing_id: int):
    return db.query(ListingAmenity).filter(ListingAmenity.listing_id == listing_id).all()

def delete_listing_amenity(db: Session, listing_id: int, amenity_id: int):
    la = db.query(ListingAmenity).filter_by(listing_id=listing_id, amenity_id=amenity_id).first()
    if la:
        db.delete(la)
        db.commit()
        return True
    return False
