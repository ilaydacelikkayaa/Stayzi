"""make email nullable

Revision ID: 3a692c8ca4c5
Revises: 
Create Date: 2025-07-11 20:05:16.867332
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '3a692c8ca4c5'
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.alter_column('users', 'email',
               existing_type=sa.TEXT(),
               type_=sa.String(),
               nullable=True)
    op.alter_column('users', 'password_hash',
               existing_type=sa.TEXT(),
               type_=sa.String(),
               existing_nullable=False)
    op.alter_column('users', 'name',
               existing_type=sa.TEXT(),
               type_=sa.String(),
               nullable=True)
    op.alter_column('users', 'surname',
               existing_type=sa.TEXT(),
               type_=sa.String(),
               nullable=True)
    op.alter_column('users', 'phone',
               existing_type=sa.TEXT(),
               type_=sa.String(),
               existing_nullable=True)
    op.alter_column('users', 'country',
               existing_type=sa.TEXT(),
               type_=sa.String(),
               existing_nullable=True)
    op.alter_column('users', 'profile_image',
               existing_type=sa.TEXT(),
               type_=sa.String(),
               existing_nullable=True)
    op.alter_column('users', 'created_at',
               existing_type=postgresql.TIMESTAMP(timezone=True),
               type_=sa.Date(),
               nullable=False,
               existing_server_default=sa.text('now()'))
    op.create_index(op.f('ix_users_email'), 'users', ['email'], unique=True)
    op.create_index(op.f('ix_users_id'), 'users', ['id'], unique=False)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index(op.f('ix_users_id'), table_name='users')
    op.drop_index(op.f('ix_users_email'), table_name='users')

    op.alter_column('users', 'created_at',
               existing_type=sa.Date(),
               type_=postgresql.TIMESTAMP(timezone=True),
               nullable=True,
               existing_server_default=sa.text('now()'))

    op.alter_column('users', 'profile_image',
               existing_type=sa.String(),
               type_=sa.TEXT(),
               existing_nullable=True)

    op.alter_column('users', 'country',
               existing_type=sa.String(),
               type_=sa.TEXT(),
               existing_nullable=True)

    op.alter_column('users', 'phone',
               existing_type=sa.String(),
               type_=sa.TEXT(),
               existing_nullable=True)

    op.alter_column('users', 'surname',
               existing_type=sa.String(),
               type_=sa.TEXT(),
               nullable=False)

    op.alter_column('users', 'name',
               existing_type=sa.String(),
               type_=sa.TEXT(),
               nullable=False)

    op.alter_column('users', 'password_hash',
               existing_type=sa.String(),
               type_=sa.TEXT(),
               existing_nullable=False)

    op.alter_column('users', 'email',
               existing_type=sa.String(),
               type_=sa.TEXT(),
               nullable=False)