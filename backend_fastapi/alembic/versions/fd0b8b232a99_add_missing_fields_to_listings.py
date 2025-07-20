"""add_missing_fields_to_listings

Revision ID: fd0b8b232a99
Revises: 58fde37a9b74
Create Date: 2025-07-20 02:11:35.991550

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'fd0b8b232a99'
down_revision: Union[str, Sequence[str], None] = '58fde37a9b74'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # Sadece eksik olan alanları ekle
    # room_count, bed_count, bathroom_count alanları zaten mevcut olabilir
    # Bu yüzden IF NOT EXISTS kontrolü yapalım
    
    # PostgreSQL'de kolon varlığını kontrol etmek için
    # Önce mevcut kolonları kontrol edelim
    connection = op.get_bind()
    
    # room_count kolonu var mı kontrol et
    result = connection.execute(sa.text("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'listings' AND column_name = 'room_count'
    """))
    if not result.fetchone():
        op.add_column('listings', sa.Column('room_count', sa.Integer(), nullable=True))
        print("room_count kolonu eklendi")
    
    # bed_count kolonu var mı kontrol et
    result = connection.execute(sa.text("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'listings' AND column_name = 'bed_count'
    """))
    if not result.fetchone():
        op.add_column('listings', sa.Column('bed_count', sa.Integer(), nullable=True))
        print("bed_count kolonu eklendi")
    
    # bathroom_count kolonu var mı kontrol et
    result = connection.execute(sa.text("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'listings' AND column_name = 'bathroom_count'
    """))
    if not result.fetchone():
        op.add_column('listings', sa.Column('bathroom_count', sa.Integer(), nullable=True))
        print("bathroom_count kolonu eklendi")


def downgrade() -> None:
    """Downgrade schema."""
    # Eklenen kolonları kaldır (eğer varsa)
    connection = op.get_bind()
    
    # room_count kolonu var mı kontrol et
    result = connection.execute(sa.text("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'listings' AND column_name = 'room_count'
    """))
    if result.fetchone():
        op.drop_column('listings', 'room_count')
    
    # bed_count kolonu var mı kontrol et
    result = connection.execute(sa.text("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'listings' AND column_name = 'bed_count'
    """))
    if result.fetchone():
        op.drop_column('listings', 'bed_count')
    
    # bathroom_count kolonu var mı kontrol et
    result = connection.execute(sa.text("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'listings' AND column_name = 'bathroom_count'
    """))
    if result.fetchone():
        op.drop_column('listings', 'bathroom_count')
