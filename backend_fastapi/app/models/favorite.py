from sqlalchemy import Column, Integer, ForeignKey, DateTime, func, Text
from app.db.session import Base

class Favorite(Base):
    __tablename__ = "favorites"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    listing_id = Column(Integer, nullable=False)
    list_name = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
