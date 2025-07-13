from app.dependencies import get_current_user 
from app.models.user import User 
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.schemas.listing import Listing, ListingCreate
from app.crud.listing import create_listing, get_listing, get_listings, delete_listing, update_listing
from app.db.dependency import get_db

router = APIRouter(
    prefix="/listings",
    tags=["listings"]
)

@router.post("/", response_model=Listing)
def create_listing_route(
    listing: ListingCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return create_listing(db=db, listing=listing, user_id=current_user.id)

@router.get("/", response_model=List[Listing])
def read_listings(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return get_listings(db, skip=skip, limit=limit)

@router.get("/{listing_id}", response_model=Listing)
def read_listing(listing_id: int, db: Session = Depends(get_db)):
    db_listing = get_listing(db, listing_id)
    if not db_listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    return db_listing

@router.delete("/{listing_id}", response_model=Listing)
def delete(listing_id: int, db: Session = Depends(get_db)):
    db_listing = delete_listing(db, listing_id)
    if not db_listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    return db_listing

@router.put("/{listing_id}", response_model=Listing)
def update(listing_id: int, listing: ListingCreate, db: Session = Depends(get_db)):
    db_listing = update_listing(db, listing_id, listing)
    if not db_listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    return db_listing 