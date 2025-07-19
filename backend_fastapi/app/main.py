import logging
from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from sqlalchemy import text
import os
from dotenv import load_dotenv
from app.routers import booking
# Routers
from app.routers import review
from app.routers import user, auth, listing, favorite, amenity, listing_amenity
from fastapi.middleware.cors import CORSMiddleware

# DB
from app.db.session import engine
from app.utils.redis_client import test_redis_connection, RedisCache, is_redis_available
from app.middleware.rate_limit import rate_limit_middleware

# 🌐 Logger ayarı
logging.basicConfig(level=logging.DEBUG)

# 🌐 Ortam değişkenlerini yükle
load_dotenv()

# ✅ FastAPI uygulaması
app = FastAPI()

# ✅ Router'ları dahil et
app.include_router(user.router)
app.include_router(auth.router)
app.include_router(listing.router)
app.include_router(favorite.router)
app.include_router(amenity.router)
app.include_router(listing_amenity.router)

# ✅ Root endpoint
@app.get("/")
def read_root():
    return {"message": "Airbnb clone API is working!"}

# ✅ Veritabanı bağlantı testi
@app.get("/test-db")
def test_db():
    try:
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            rows = [dict(row._mapping) for row in result]
            return {"success": True, "result": rows}
    except Exception as e:
        return {"success": False, "error": str(e)}

# ✅ Redis bağlantı testi
@app.get("/test-redis")
async def test_redis():
    try:
        is_connected = await test_redis_connection()
        return {"success": is_connected, "message": "Redis connection test"}
    except Exception as e:
        return {"success": False, "error": str(e)}

# ✅ Redis cache test endpoint'leri
@app.post("/test-cache")
async def test_cache_set():
    """Redis cache'e test verisi yaz"""
    try:
        if not await is_redis_available():
            return {"success": False, "message": "Redis not available"}
        
        test_data = {"message": "Hello from Redis!", "timestamp": "2024-01-01"}
        success = await RedisCache.set_cache("test_key", test_data, expire=300)
        return {"success": success, "message": "Test data cached"}
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.get("/test-cache")
async def test_cache_get():
    """Redis cache'den test verisi oku"""
    try:
        if not await is_redis_available():
            return {"success": False, "message": "Redis not available"}
        
        cached_data = await RedisCache.get_cache("test_key")
        return {"success": True, "data": cached_data}
    except Exception as e:
        return {"success": False, "error": str(e)}

# ✅ uploads klasörünü statik olarak sun
if not os.path.exists("uploads"):
    os.makedirs("uploads")

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Rate limiting middleware ekle
@app.middleware("http")
async def rate_limit(request: Request, call_next):
    return await rate_limit_middleware(request, call_next)

app.include_router(booking.router)

app.include_router(review.router)
from app.routers import availability
app.include_router(availability.router)
