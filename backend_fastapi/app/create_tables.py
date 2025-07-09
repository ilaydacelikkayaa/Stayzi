from app.db.session import engine, Base
from app.models.user import User
from app.models.listing import Listing

if __name__ == "__main__":
    Base.metadata.create_all(bind=engine)
    print("Tüm tablolar başarıyla oluşturuldu.")
    print(engine.url) 