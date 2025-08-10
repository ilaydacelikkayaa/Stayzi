#!/usr/bin/env python3
"""
Script to add default amenities to the database
Run this script to populate the amenities table with common amenities
"""

import sys
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.amenity import Amenity
from app.db.session import Base

# Add the parent directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Default amenities to add - sadece makul sayıda amenity
DEFAULT_AMENITIES = [
    "WiFi",
    "Klima",
    "Mutfak",
    "Çamaşır Makinesi",
    "Bulaşık Makinesi",
    "TV",
    "Otopark",
    "Balkon",
    "Bahçe",
    "Havuz",
    "Spor Salonu",
    "Güvenlik",
    "Asansör",
    "Sigara İçilmez",
    "Evcil Hayvan Kabul",
    "Kahvaltı",
    "Özel Giriş",
    "Çalışma Masası",
    "Şömine",
    "Barbekü",
    "Çocuk Oyun Alanı",
    "Fitness Merkezi",
    "Spa",
    "Sauna",
    "Jakuzi",
]

def add_default_amenities():
    """Add default amenities to the database"""
    
    # Database connection - you may need to adjust this based on your setup
    from app.db.session import engine
    
    # Create a session
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()
    
    try:
        print("🔍 Checking existing amenities...")
        existing_amenities = db.query(Amenity).all()
        existing_names = [amenity.name for amenity in existing_amenities]
        
        print(f"📊 Found {len(existing_amenities)} existing amenities")
        
        # Add new amenities that don't exist
        added_count = 0
        for amenity_name in DEFAULT_AMENITIES:
            if amenity_name not in existing_names:
                new_amenity = Amenity(name=amenity_name)
                db.add(new_amenity)
                added_count += 1
                print(f"✅ Added: {amenity_name}")
        
        # Commit the changes
        db.commit()
        
        print(f"🎉 Successfully added {added_count} new amenities!")
        print(f"📊 Total amenities in database: {len(existing_amenities) + added_count}")
        
        # Show all amenities
        all_amenities = db.query(Amenity).all()
        print("\n📋 All amenities in database:")
        for i, amenity in enumerate(all_amenities, 1):
            print(f"  {i:3d}. {amenity.name}")
            
    except Exception as e:
        print(f"❌ Error adding amenities: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    print("🚀 Starting to add default amenities...")
    add_default_amenities()
    print("✨ Done!")
