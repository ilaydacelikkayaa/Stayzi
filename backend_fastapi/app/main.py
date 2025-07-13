import logging
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from sqlalchemy import text
import os
from dotenv import load_dotenv
from app.routers import booking
# Routers
from app.routers import user, auth, listing, favorite, amenity, listing_amenity

# DB
from app.db.session import engine

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

# ✅ uploads klasörünü statik olarak sun
if not os.path.exists("uploads"):
    os.makedirs("uploads")

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")



app.include_router(booking.router)
