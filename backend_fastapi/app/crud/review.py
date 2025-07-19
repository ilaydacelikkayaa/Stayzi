from sqlalchemy.orm import Session
from app.models.review import Review
from app.schemas.review import ReviewCreate
from typing import List
from app.schemas.review import ReviewUpdate
from app.models.listing import Listing
from sqlalchemy import func
from sqlalchemy.orm import joinedload


def create_review(db: Session, user_id: int, review: ReviewCreate) -> Review:
    db_review = Review(**review.model_dump(), user_id=user_id)
    db.add(db_review)
    db.commit()
    db.refresh(db_review)

    update_average_rating(db, review.listing_id)
    return db_review


def get_reviews_by_listing(db: Session, listing_id: int) -> List[Review]:
    return db.query(Review)\
        .options(joinedload(Review.user))\
        .filter(Review.listing_id == listing_id)\
        .all()

def update_review(db: Session, review_id: int, user_id: int, review_update: ReviewUpdate):
    review = db.query(Review).filter(Review.id == review_id, Review.user_id == user_id).first()
    if not review:
        return None
    review.rating = review_update.rating
    review.comment = review_update.comment
    db.commit()
    db.refresh(review)

    update_average_rating(db, review.listing_id)
    return review

def delete_review(db: Session, review_id: int, user_id: int):
    review = db.query(Review).filter(Review.id == review_id, Review.user_id == user_id).first()
    if not review:
        return False
    db.delete(review)
    db.commit()

    update_average_rating(db,review.listing_id)
    return True

def update_average_rating(db: Session, listing_id: int):
    average = db.query(func.avg(Review.rating)).filter(Review.listing_id == listing_id).scalar()
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if listing:
        listing.average_rating = round(average or 0, 2)
        db.commit()