from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from fastapi import File, UploadFile, Form

from app.db.session import get_db
from app.schemas.user import UserCreate, UserOut, UserUpdate
from app.crud import user as user_crud
from app.dependencies import get_current_user
from app.models.user import User
from app.utils.auth import get_current_user
from app.crud.user import update_user_by_current_user
from app.schemas.user import PhoneRegister
from app.crud.user import get_user_by_phone, create_user_from_phone, update_user_by_current_user



router = APIRouter(tags=["Users"], prefix="/users")

# 🔐 Giriş yapan kullanıcı kendi profilini görür
@router.get("/me", response_model=UserOut)
def get_my_profile(current_user: User = Depends(get_current_user)):
    return current_user

@router.put("/me", response_model=UserOut)
async def update_my_info(
    name: str = Form(None),
    surname: str = Form(None),
    email: str = Form(None),
    phone: str = Form(None),
    birthdate: str = Form(None),
    country: str = Form(None),
    file: UploadFile = File(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 📤 Profil fotoğrafı kaydet
    if file:
        filename = f"profile_{current_user.id}.jpg"
        file_path = f"uploads/{filename}"
        with open(file_path, "wb") as image:
            image.write(await file.read())
        current_user.profile_image = f"/uploads/{filename}"

    # 📝 Diğer alanları güncelle (sadece boş olmayan değerleri)
    if name and name.strip():
        current_user.name = name.strip()
    if surname and surname.strip():
        current_user.surname = surname.strip()
    if email and email.strip():
        current_user.email = email.strip()
    if phone and phone.strip():
        current_user.phone = phone.strip()
    if birthdate and birthdate.strip():
        current_user.birthdate = birthdate
    if country and country.strip():
        current_user.country = country.strip()

    db.commit()
    db.refresh(current_user)
    return current_user
# ✅ Tüm kullanıcıları getir (admin için)
@router.get("/", response_model=List[UserOut])
def list_users(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return user_crud.get_users(db)

# ✅ Belirli bir kullanıcıyı ID ile getir
@router.get("/id/{user_id}", response_model=UserOut)
def get_user_by_id(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    user = user_crud.get_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# ✅ Kullanıcı oluştur
@router.post("/", response_model=UserOut)
def create_user(
    user: UserCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return user_crud.create_user(db, user)

# ✅ Kullanıcı sil
@router.delete("/id/{user_id}", response_model=UserOut)
def delete_user_route(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    user = user_crud.delete_user(db, user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# ✅ Kullanıcı güncelle
@router.put("/id/{user_id}", response_model=UserOut)
def update_user_route(
    user_id: int,
    user_data: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    user = user_crud.update_user(db, user_id, user_data)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# 📩 E-posta ile kayıt
@router.post("/register", response_model=UserOut)
def register_user(user_in: UserCreate, db: Session = Depends(get_db)):
    existing_user = user_crud.get_user_by_email(db, user_in.email)
    if existing_user:
        raise HTTPException(status_code=400, detail="E-posta zaten kayıtlı")

    return user_crud.create_user(db, user_in)

# 📱 Telefonla kayıt
@router.post("/register-phone", response_model=UserOut)
def register_with_phone(user: PhoneRegister, db: Session = Depends(get_db)):
    if not user.phone:
        raise HTTPException(status_code=400, detail="Telefon numarası gereklidir")

    existing_user = get_user_by_phone(db, user.phone)
    if existing_user:
        raise HTTPException(status_code=400, detail="Bu telefon numarasıyla kayıtlı bir kullanıcı var")

    return create_user_from_phone(db, user)

@router.delete("/me")
def deactivate_my_account(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    current_user.is_active = False
    db.commit()
    return {"message": "Hesabınız devre dışı bırakıldı."}

@router.get("/phone-exists/{phone}")
def check_phone_exists(phone: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.phone == phone).first()
    return {"exists": user is not None}


@router.get("/email-exists/{email}")
def check_email_exists(email: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == email).first()
    return {"exists": user is not None}
