from fastapi import FastAPI
from app.routers import user, auth
from app.db.session import engine
from sqlalchemy import text

from dotenv import load_dotenv
load_dotenv()


app = FastAPI()

# 🔥 Tüm router'ları tek app ile tanımla
app.include_router(user.router, prefix="/users")
app.include_router(auth.router)

@app.get("/")
def read_root():
    return {"message": "Airbnb clone API is working!"}

@app.get("/test-db")
def test_db():
    try:
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            rows = [dict(row._mapping) for row in result]
            return {"success": True, "result": rows}
    except Exception as e:
        return {"success": False, "error": str(e)}
