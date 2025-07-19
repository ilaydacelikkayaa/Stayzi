from app.dependencies import get_current_user 
from fastapi import APIRouter, Depends, HTTPException, File, UploadFile, Form
from sqlalchemy.orm import Session
from typing import List, Optional
from app.schemas.listing import Listing, ListingCreate
from app.crud.listing import create_listing, get_listing, get_listings, delete_listing, update_listing, get_listings_by_user
from app.db.dependency import get_db
from app.utils.redis_client import RedisCache, RateLimiter, is_redis_available
import os
import shutil
from datetime import datetime
from app.models.review import Review
from fastapi.responses import JSONResponse
from app.models.user import User
from app.models.listing import Listing as ListingModel
from app.schemas.amenity import Amenity

router = APIRouter(
    prefix="/listings",
    tags=["listings"]
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
    allow_events: Optional[str] = Form(None),  # "true" veya "false" string olarak gelecek
    allow_smoking: Optional[str] = Form(None),  # "true" veya "false" string olarak gelecek
    allow_commercial_photo: Optional[str] = Form(None),  # "true" veya "false" string olarak gelecek
    max_guests: Optional[int] = Form(None),
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

    amenities_list = None
    if amenities:
        print(f"DEBUG - Router Update: Gelen amenities string = {amenities}")
        try:
            import json
            amenities_data = json.loads(amenities)
            print(f"DEBUG - Router Update: Parsed amenities data = {amenities_data}")
            # String listesi ise AmenityInListing objelerine dönüştür
            if isinstance(amenities_data, list) and all(isinstance(item, str) for item in amenities_data):
                amenities_list = []
                for i, amenity_name in enumerate(amenities_data):
                    amenities_list.append({
                        "id": i + 1,  # Geçici ID
                        "name": amenity_name
                    })
                print(f"DEBUG - Router Update: String listesi AmenityInListing'e dönüştürüldü = {amenities_list}")
            else:
                amenities_list = amenities_data
                print(f"DEBUG - Router Update: Zaten doğru format = {amenities_list}")
        except Exception as e:
            print(f"DEBUG - Router Update: JSON parse hatası = {e}")
            # Tek string ise listeye çevir
            amenities_list = [{"id": 1, "name": amenities}]
            print(f"DEBUG - Router Update: Tek string listeye çevrildi = {amenities_list}")
    else:
        print(f"DEBUG - Router Update: Amenities parametresi yok")
    
    # Boolean string'leri parse et
    allow_events_bool = allow_events == "true" if allow_events else False
    allow_smoking_bool = allow_smoking == "true" if allow_smoking else False
    allow_commercial_photo_bool = allow_commercial_photo == "true" if allow_commercial_photo else False
    
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
        "amenities": amenities_list,
        "allow_events": allow_events_bool,
        "allow_smoking": allow_smoking_bool,
        "allow_commercial_photo": allow_commercial_photo_bool,
        "max_guests": max_guests
    }

    listing = ListingCreate(**listing_data)
    db_listing = create_listing(db=db, listing=listing, user_id=current_user.id)
    user = db.query(User).filter(User.id == db_listing.user_id).first()
    listing_dict = db_listing.__dict__.copy()
    listing_dict['user'] = user
    return listing_dict

@router.get("/", response_model=List[Listing])
def read_listings(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    listings = get_listings(db, skip=skip, limit=limit)
    result = []
    for l in listings:
        d = l.__dict__.copy()
        d['user'] = db.query(User).filter(User.id == l.user_id).first()
        result.append(d)
        
        # Debug: İlk listing'in verilerini yazdır
        if len(result) == 1:
            print(f"DEBUG - Backend GET / (first listing):")
            print(f"SQLAlchemy objesi: {l.__dict__}")
            print(f"Final response: {d}")
    
    return result

@router.get("/my-listings", response_model=List[Listing])
def read_my_listings(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    listings = get_listings_by_user(db, current_user.id, skip=skip, limit=limit)
    result = []
    for l in listings:
        # Amenities'i doğru şekilde serialize et
        amenities_data = []
        if l.amenities:
            for amenity in l.amenities:
                amenities_data.append({
                    "id": amenity.id,
                    "name": amenity.name
                })
        
        print(f"DEBUG - Backend GET /my-listings: Listing {l.id} amenities = {amenities_data}")
        
        d = {
            "id": l.id,
            "user_id": l.user_id,
            "title": l.title,
            "description": l.description,
            "price": float(l.price) if l.price else None,
            "location": l.location,
            "lat": l.lat,
            "lng": l.lng,
            "home_type": l.home_type,
            "host_languages": l.host_languages,
            "image_urls": l.image_urls,
            "created_at": l.created_at,
            "average_rating": float(l.average_rating) if l.average_rating else 0.0,
            "home_rules": l.home_rules,
            "capacity": l.capacity,
            "amenities": amenities_data,
            "bed_count": l.bed_count,
            "room_count": l.room_count,
            "bathroom_count": l.bathroom_count,
            "allow_events": l.allow_events,
            "allow_smoking": l.allow_smoking,
            "allow_commercial_photo": l.allow_commercial_photo,
            "max_guests": l.max_guests,
            "user": db.query(User).filter(User.id == l.user_id).first()
        }
        result.append(d)
    return result

@router.get("/{listing_id}", response_model=Listing)
async def read_listing(listing_id: int, db: Session = Depends(get_db)):
    # Redis kullanılabilir mi kontrol et
    if await is_redis_available():
        # Redis'ten önbellekteki veriyi kontrol et
        cache_key = f"listing:{listing_id}"
        cached_listing = await RedisCache.get_cache(cache_key)
        
        if cached_listing:
            print(f"DEBUG - Listing {listing_id} Redis'ten alındı")
            return cached_listing
    
    # Veritabanından veri çek
    db_listing = get_listing(db, listing_id)
    if not db_listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    user = db.query(User).filter(User.id == db_listing.user_id).first()
    review_count = db.query(Review).filter(Review.listing_id == db_listing.id).count()
    
    # Amenities'i doğru şekilde serialize et
    amenities_data = []
    if db_listing.amenities:
        for amenity in db_listing.amenities:
            amenities_data.append({
                "id": amenity.id,
                "name": amenity.name
            })
    
    print(f"DEBUG - Backend GET /{listing_id}: Amenities serialize edildi = {amenities_data}")
    
    # Listing şemasına uygun dict oluştur
    listing_dict = {
        "id": db_listing.id,
        "user_id": db_listing.user_id,
        "title": db_listing.title,
        "description": db_listing.description,
        "price": float(db_listing.price) if db_listing.price else None,
        "location": db_listing.location,
        "lat": db_listing.lat,
        "lng": db_listing.lng,
        "home_type": db_listing.home_type,
        "host_languages": db_listing.host_languages,
        "image_urls": db_listing.image_urls,
        "created_at": db_listing.created_at,
        "average_rating": float(db_listing.average_rating) if db_listing.average_rating else 0.0,
        "home_rules": db_listing.home_rules,
        "capacity": db_listing.capacity,
        "amenities": amenities_data,
        "bed_count": db_listing.bed_count,
        "room_count": db_listing.room_count,
        "bathroom_count": db_listing.bathroom_count,
        "allow_events": db_listing.allow_events,
        "allow_smoking": db_listing.allow_smoking,
        "allow_commercial_photo": db_listing.allow_commercial_photo,
        "max_guests": db_listing.max_guests,
        "user": user,
        "review_count": review_count
    }
    
    # Debug: SQLAlchemy objesinin tüm alanlarını yazdır
    print(f"DEBUG - Backend GET /{listing_id}:")
    print(f"SQLAlchemy objesi: {db_listing.__dict__}")
    print(f"Amenities: {amenities_data}")
    print(f"Final response: {listing_dict}")
    
    # Redis kullanılabilirse kaydet
    if await is_redis_available():
        cache_key = f"listing:{listing_id}"
        await RedisCache.set_cache(cache_key, listing_dict, expire=3600)
        print(f"DEBUG - Listing {listing_id} Redis'e kaydedildi")
    else:
        print(f"DEBUG - Redis kullanılamıyor, listing {listing_id} cache'lenmedi")
    
    return listing_dict

@router.delete("/{listing_id}", response_model=Listing)
async def delete(listing_id: int, db: Session = Depends(get_db)):
    db_listing = delete_listing(db, listing_id)
    if not db_listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    
    # Redis kullanılabilirse önbelleği temizle
    if await is_redis_available():
        cache_key = f"listing:{listing_id}"
        await RedisCache.delete_cache(cache_key)
        print(f"DEBUG - Listing {listing_id} Redis önbelleği temizlendi")
    else:
        print(f"DEBUG - Redis kullanılamıyor, listing {listing_id} önbelleği temizlenmedi")
    
    user = db.query(User).filter(User.id == db_listing.user_id).first()
    listing_dict = db_listing.__dict__.copy()
    listing_dict['user'] = user
    return listing_dict



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
    allow_events: Optional[str] = Form(None),
    allow_smoking: Optional[str] = Form(None),
    allow_commercial_photo: Optional[str] = Form(None),
    max_guests: Optional[int] = Form(None),
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
    host_languages_list = None
    if host_languages:
        try:
            import json
            host_languages_list = json.loads(host_languages)
        except:
            host_languages_list = [host_languages]

    amenities_list = None
    if amenities:
        print(f"DEBUG - Router Update: Gelen amenities string = {amenities}")
        try:
            import json
            amenities_data = json.loads(amenities)
            print(f"DEBUG - Router Update: Parsed amenities data = {amenities_data}")
            # String listesi ise AmenityInListing objelerine dönüştür
            if isinstance(amenities_data, list) and all(isinstance(item, str) for item in amenities_data):
                amenities_list = []
                for i, amenity_name in enumerate(amenities_data):
                    amenities_list.append({
                        "id": i + 1,  # Geçici ID
                        "name": amenity_name
                    })
                print(f"DEBUG - Router Update: String listesi AmenityInListing'e dönüştürüldü = {amenities_list}")
            else:
                amenities_list = amenities_data
                print(f"DEBUG - Router Update: Zaten doğru format = {amenities_list}")
        except Exception as e:
            print(f"DEBUG - Router Update: JSON parse hatası = {e}")
            # Tek string ise listeye çevir
            amenities_list = [{"id": 1, "name": amenities}]
            print(f"DEBUG - Router Update: Tek string listeye çevrildi = {amenities_list}")
    else:
        print(f"DEBUG - Router Update: Amenities parametresi yok")

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
    
    # Boolean string'leri parse et ve ekle
    if allow_events is not None:
        listing_data["allow_events"] = allow_events == "true"
        print(f"DEBUG - Backend Update: allow_events = {allow_events} -> {allow_events == 'true'}")
    if allow_smoking is not None:
        listing_data["allow_smoking"] = allow_smoking == "true"
        print(f"DEBUG - Backend Update: allow_smoking = {allow_smoking} -> {allow_smoking == 'true'}")
    if allow_commercial_photo is not None:
        listing_data["allow_commercial_photo"] = allow_commercial_photo == "true"
        print(f"DEBUG - Backend Update: allow_commercial_photo = {allow_commercial_photo} -> {allow_commercial_photo == 'true'}")
    if max_guests is not None:
        listing_data["max_guests"] = max_guests
        print(f"DEBUG - Backend Update: max_guests = {max_guests}")
    
    listing = ListingCreate(**listing_data)
    updated_listing = update_listing(db, listing_id, listing)
    
    # Response'u doğru şekilde formatla
    user = db.query(User).filter(User.id == updated_listing.user_id).first()
    
    # Amenities'i doğru şekilde serialize et
    amenities_data = []
    if updated_listing.amenities:
        for amenity in updated_listing.amenities:
            amenities_data.append({
                "id": amenity.id,
                "name": amenity.name
            })
    
    print(f"DEBUG - Backend Update Response: Amenities serialize edildi = {amenities_data}")
    
    response_dict = {
        "id": updated_listing.id,
        "user_id": updated_listing.user_id,
        "title": updated_listing.title,
        "description": updated_listing.description,
        "price": float(updated_listing.price) if updated_listing.price else None,
        "location": updated_listing.location,
        "lat": updated_listing.lat,
        "lng": updated_listing.lng,
        "home_type": updated_listing.home_type,
        "host_languages": updated_listing.host_languages,
        "image_urls": updated_listing.image_urls,
        "created_at": updated_listing.created_at,
        "average_rating": float(updated_listing.average_rating) if updated_listing.average_rating else 0.0,
        "home_rules": updated_listing.home_rules,
        "capacity": updated_listing.capacity,
        "amenities": amenities_data,
        "bed_count": updated_listing.bed_count,
        "room_count": updated_listing.room_count,
        "bathroom_count": updated_listing.bathroom_count,
        "allow_events": updated_listing.allow_events,
        "allow_smoking": updated_listing.allow_smoking,
        "allow_commercial_photo": updated_listing.allow_commercial_photo,
        "max_guests": updated_listing.max_guests,
        "user": user
    }
    
    # Redis kullanılabilirse önbelleği temizle
    if await is_redis_available():
        cache_key = f"listing:{listing_id}"
        await RedisCache.delete_cache(cache_key)
        print(f"DEBUG - Listing {listing_id} Redis önbelleği güncelleme sonrası temizlendi")
    else:
        print(f"DEBUG - Redis kullanılamıyor, listing {listing_id} önbelleği temizlenmedi")
    
    return response_dict


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