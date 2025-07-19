from app.dependencies import get_current_user
from fastapi import APIRouter, Depends, HTTPException, File, UploadFile, Form, Query
from app.schemas.listing import Listing, ListingCreate, ListingOut
from app.crud.listing import create_listing, get_listing, get_listings, delete_listing, update_listing, get_listings_by_user
import os
import shutil
from fastapi.responses import JSONResponse
from app.models.user import User
from app.models.listing import Listing as ListingModel
from app.schemas.amenity import Amenity

from datetime import datetime
from fastapi import APIRouter, Query, Depends
from typing import Optional, List
from sqlalchemy.orm import Session
from app.schemas.listing import Listing
from app.db.dependency import get_db

router = APIRouter(
    prefix="/listings",
    tags=["listings"]
)

@router.get("/filter", response_model=List[ListingOut])
def filter_listings(
    location:  Optional[str]  = Query(None),
    start_date: Optional[str] = Query(None),
    end_date:   Optional[str] = Query(None),
    guests:     Optional[int]  = Query(None),
    min_price:  Optional[float]= Query(None, alias="min_price"),
    max_price:  Optional[float]= Query(None, alias="max_price"),
    db:         Session        = Depends(get_db),
):
    sd = datetime.fromisoformat(start_date).date() if start_date else None
    ed = datetime.fromisoformat(end_date).date()   if end_date   else None

    return get_filtered_listings(
        db,
        location=location,
        start_date=sd,
        end_date=ed,
        guests=guests,
        min_price=min_price,
        max_price=max_price
    )
@router.post("/", response_model=Listing)
async def create_listing_route(
    title: str = Form(...),
    description: Optional[str] = Form(None),
    price: float = Form(...),
    location: Optional[str] = Form(None),
    lat: Optional[float] = Form(None),
    lng: Optional[float] = Form(None),
    home_type: Optional[str] = Form(None),
    host_languages: Optional[str] = Form(None),  # JSON string olarak gelecek
    home_rules: Optional[str] = Form(None),
    capacity: Optional[int] = Form(None),
    amenities: Optional[str] = Form(None),  # JSON string olarak gelecek
    photo: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Fotoğrafı kaydet
    image_urls = []
    if photo:
        # Uploads klasörünü oluştur
        upload_dir = "uploads/listings"
        os.makedirs(upload_dir, exist_ok=True)

        # Benzersiz dosya adı oluştur
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        file_extension = os.path.splitext(photo.filename)[1] if photo.filename else ".jpg"
        filename = f"listing_{current_user.id}_{timestamp}{file_extension}"
        file_path = os.path.join(upload_dir, filename)

        # Dosyayı kaydet
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(photo.file, buffer)

        image_urls.append(f"/uploads/listings/{filename}")

    # JSON string'leri parse et
    host_languages_list = []
    if host_languages:
        try:
            import json
            host_languages_list = json.loads(host_languages)
        except:
            host_languages_list = [host_languages]

    amenities_list = []
    if amenities:
        try:
            import json
            amenities_list = json.loads(amenities)
        except:
            amenities_list = [amenities]

    # ListingCreate objesi oluştur
    listing_data = {
        "title": title,
        "description": description,
        "price": price,
        "location": location,
        "lat": lat,
        "lng": lng,
        "home_type": home_type,
        "host_languages": host_languages_list,
        "image_urls": image_urls,
        "home_rules": home_rules,
        "capacity": capacity,
        "amenities": amenities_list
    }

    listing = ListingCreate(**listing_data)
    return create_listing(db=db, listing=listing, user_id=current_user.id)

@router.get("/", response_model=List[Listing])
def read_listings(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return get_listings(db, skip=skip, limit=limit)

@router.get("/my-listings", response_model=List[Listing])
def read_my_listings(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return get_listings_by_user(db, current_user.id, skip=skip, limit=limit)

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
async def update(
    listing_id: int,
    title: Optional[str] = Form(None),
    description: Optional[str] = Form(None),
    price: Optional[float] = Form(None),
    location: Optional[str] = Form(None),
    lat: Optional[float] = Form(None),
    lng: Optional[float] = Form(None),
    home_type: Optional[str] = Form(None),
    host_languages: Optional[str] = Form(None),
    home_rules: Optional[str] = Form(None),
    capacity: Optional[int] = Form(None),
    amenities: Optional[str] = Form(None),
    photo: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Mevcut listing'i al
    db_listing = get_listing(db, listing_id)
    if not db_listing:
        raise HTTPException(status_code=404, detail="Listing not found")

    # Kullanıcının kendi listing'ini güncelleyip güncelleyemediğini kontrol et
    if db_listing.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to update this listing")

    # Fotoğrafı kaydet
    image_urls = db_listing.image_urls or []
    if photo:
        upload_dir = "uploads/listings"
        os.makedirs(upload_dir, exist_ok=True)

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        file_extension = os.path.splitext(photo.filename)[1] if photo.filename else ".jpg"
        filename = f"listing_{current_user.id}_{timestamp}{file_extension}"
        file_path = os.path.join(upload_dir, filename)

        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(photo.file, buffer)
        image_urls = [f"/uploads/listings/{filename}"] + image_urls  # Yeni fotoğrafı başa ekle


        image_urls.append(f"/uploads/listings/{filename}")

    # JSON string'leri parse et
    host_languages_list = None
    if host_languages:
        try:
            import json
            host_languages_list = json.loads(host_languages)
        except:
            host_languages_list = [host_languages]

    amenities_list = None
    if amenities:
        try:
            import json
            amenities_list = json.loads(amenities)
        except:
            amenities_list = [amenities]

    # ListingCreate objesi oluştur
    listing_data = {}
    if title is not None:
        listing_data["title"] = title
    if description is not None:
        listing_data["description"] = description
    if price is not None:
        listing_data["price"] = price
    if location is not None:
        listing_data["location"] = location
    if lat is not None:
        listing_data["lat"] = lat
    if lng is not None:
        listing_data["lng"] = lng
    if home_type is not None:
        listing_data["home_type"] = home_type
    if host_languages_list is not None:
        listing_data["host_languages"] = host_languages_list
    # image_urls her zaman güncellenmeli!
    listing_data["image_urls"] = image_urls
    if home_rules is not None:
        listing_data["home_rules"] = home_rules
    if capacity is not None:
        listing_data["capacity"] = capacity
    if amenities_list is not None:
        listing_data["amenities"] = amenities_list

    listing = ListingCreate(**listing_data)
    return update_listing(db, listing_id, listing)


from app.crud import listing_amenity

@router.get("/{listing_id}/with-host")
def read_listing_with_host(listing_id: int, db: Session = Depends(get_db)):
    listing = db.query(ListingModel).filter(ListingModel.id == listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")

    user = db.query(User).filter(User.id == listing.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Host not found")


    amenities = listing_amenity.get_amenities_for_listing(db, listing_id)
    amenities_data = [Amenity.model_validate(a).model_dump() for a in amenities]

    listing_data = {
        "id": listing.id,
        "title": listing.title,
        "description": listing.description,
        "price": float(listing.price) if listing.price else None,
        "location": listing.location,
        "lat": listing.lat,
        "lng": listing.lng,
        "home_type": listing.home_type,
        "image_urls": listing.image_urls,
        "average_rating": float(listing.average_rating) if listing.average_rating else 0.0,
        "home_rules": listing.home_rules,
        "amenities": amenities_data,
        "host": {
            "id": user.id,
            "name": user.name,
            "surname": user.surname,
            "email": user.email,
            "birthdate": user.birthdate.isoformat() if user.birthdate else None,
            "phone": user.phone,
            "country": user.country,
            "profile_image": user.profile_image,
            "is_active": user.is_active,
            "created_at": user.created_at.isoformat() if user.created_at else None,
        }
    }

    return JSONResponse(content=listing_data)


from app.crud.listing import get_filtered_listings

