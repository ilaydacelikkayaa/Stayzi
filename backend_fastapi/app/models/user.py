from sqlalchemy import Column, Integer, String, Date, Boolean, func
from app.db.session import Base
from datetime import date

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=True)
    password_hash = Column(String, nullable=False)
    name = Column(String, nullable=False)
    surname = Column(String, nullable=True)  # ✅ artık boş olabilir
    birthdate = Column(Date, nullable=True)  # ✅ artık boş olabilir
    phone = Column(String, nullable=False)
    country = Column(String, nullable=True)
    profile_image = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(Date, nullable=False, default=date.today)
