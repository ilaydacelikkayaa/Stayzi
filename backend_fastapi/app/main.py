from fastapi import FastAPI
from app.routers import user, auth
from app.db.session import engine
from sqlalchemy import text
from fastapi.staticfiles import StaticFiles
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

# 🌐 API rotaları
app.include_router(user.router)
app.include_router(auth.router)

# ✅ Root endpoint
@app.get("/")
def read_root():
    return {"message": "Airbnb clone API is working!"}

# ✅ Veritabanı testi
@app.get("/test-db")
def test_db():
    try:
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            rows = [dict(row._mapping) for row in result]
            return {"success": True, "result": rows}
    except Exception as e:
        return {"success": False, "error": str(e)}

# ✅ uploads klasörü static olarak sunuluyor
if not os.path.exists("uploads"):
    os.makedirs("uploads")

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")
