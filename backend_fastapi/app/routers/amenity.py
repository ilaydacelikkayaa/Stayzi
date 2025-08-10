from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.dependency import get_db
from app.schemas.amenity import Amenity, AmenityCreate
from app.crud.amenity import create_amenity, get_all_amenities, get_amenity, delete_amenity

router = APIRouter(
    prefix="/amenities",
    tags=["amenities"]
)

@router.post("/", response_model=Amenity)
def create(amenity: AmenityCreate, db: Session = Depends(get_db)):
    return create_amenity(db, amenity)

@router.get("/", response_model=list[Amenity])
def read_all(db: Session = Depends(get_db)):
    amenities = get_all_amenities(db)
    print(f"🔍 Backend - Returning {len(amenities)} amenities:")
    for amenity in amenities:
        print(f"   - ID: {amenity.id}, Name: '{amenity.name}' (type: {type(amenity.name)})")
    return amenities

@router.get("/{amenity_id}", response_model=Amenity)
def read_one(amenity_id: int, db: Session = Depends(get_db)):
    amenity = get_amenity(db, amenity_id)
    if not amenity:
        raise HTTPException(status_code=404, detail="Özellik bulunamadı")
    return amenity

@router.delete("/{amenity_id}")
def delete(amenity_id: int, db: Session = Depends(get_db)):
    success = delete_amenity(db, amenity_id)
    if not success:
        raise HTTPException(status_code=404, detail="Silinecek özellik bulunamadı")
    return {"message": "Özellik başarıyla silindi"}
