from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.schemas.listing_amenity import ListingAmenityCreate
from app.crud import listing_amenity

router = APIRouter(prefix="/listing-amenities", tags=["listing-amenities"])

@router.post("/")
def create_listing_amenity_api(la: ListingAmenityCreate, db: Session = Depends(get_db)):
    return listing_amenity.create_listing_amenity(db, la)

@router.get("/listing/{listing_id}")
def get_amenities_for_listing_api(listing_id: int, db: Session = Depends(get_db)):
    return listing_amenity.get_amenities_for_listing(db, listing_id)

@router.delete("/")
def delete_listing_amenity_api(listing_id: int, amenity_id: int, db: Session = Depends(get_db)):
    success = listing_amenity.delete_listing_amenity(db, listing_id, amenity_id)
    if not success:
        raise HTTPException(status_code=404, detail="Eşleşme bulunamadı")
    return {"message": "Silindi"}
