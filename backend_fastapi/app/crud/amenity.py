from sqlalchemy.orm import Session
from app.models.amenity import Amenity
from app.schemas.amenity import AmenityCreate
from typing import List, Optional

def create_amenity(db: Session, amenity: AmenityCreate) -> Amenity:
    db_amenity = Amenity(**amenity.model_dump())
    db.add(db_amenity)
    db.commit()
    db.refresh(db_amenity)
    return db_amenity

def get_all_amenities(db: Session) -> List[Amenity]:
    return db.query(Amenity).all()

def get_amenity(db: Session, amenity_id: int) -> Optional[Amenity]:
    return db.query(Amenity).filter(Amenity.id == amenity_id).first()

def delete_amenity(db: Session, amenity_id: int) -> bool:
    amenity = db.query(Amenity).filter(Amenity.id == amenity_id).first()
    if amenity:
        db.delete(amenity)
        db.commit()
        return True
    return False
