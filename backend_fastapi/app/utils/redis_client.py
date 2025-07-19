import redis.asyncio as redis
import json
import logging
from typing import Optional, Any, Dict, List
from datetime import timedelta, datetime
import os
from dotenv import load_dotenv

load_dotenv()

# Redis bağlantı ayarları
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
REDIS_DB = int(os.getenv("REDIS_DB", 0))
REDIS_PASSWORD = os.getenv("REDIS_PASSWORD", None)

# Asenkron Redis client
async def get_redis_client():
    """Asenkron Redis client döndürür"""
    return redis.Redis(
        host=REDIS_HOST,
        port=REDIS_PORT,
        db=REDIS_DB,
        password=REDIS_PASSWORD,
        decode_responses=True
    )

class RedisCache:
    """Redis önbellekleme işlemleri için yardımcı sınıf"""
    
    @staticmethod
    async def set_cache(key: str, value: Any, expire: int = 3600) -> bool:
        """Veriyi Redis'e kaydet"""
        try:
            redis_conn = await get_redis_client()
            if isinstance(value, (dict, list)):
                # Datetime objelerini string'e çevir
                def datetime_converter(obj):
                    if isinstance(obj, datetime):
                        return obj.isoformat()
                    elif hasattr(obj, '__dict__'):
                        return obj.__dict__
                    return str(obj)
                
                value = json.dumps(value, default=datetime_converter)
            await redis_conn.set(key, value, ex=expire)
            await redis_conn.close()
            return True
        except Exception as e:
            logging.error(f"Redis set error: {e}")
            return False
    
    @staticmethod
    async def get_cache(key: str) -> Optional[Any]:
        """Redis'ten veri oku"""
        try:
            redis_conn = await get_redis_client()
            value = await redis_conn.get(key)
            await redis_conn.close()
            
            if value:
                try:
                    return json.loads(value)
                except json.JSONDecodeError:
                    return value
            return None
        except Exception as e:
            logging.error(f"Redis get error: {e}")
            return None
    
    @staticmethod
    async def delete_cache(key: str) -> bool:
        """Redis'ten veri sil"""
        try:
            redis_conn = await get_redis_client()
            result = await redis_conn.delete(key)
            await redis_conn.close()
            return result > 0
        except Exception as e:
            logging.error(f"Redis delete error: {e}")
            return False
    
    @staticmethod
    async def exists_cache(key: str) -> bool:
        """Anahtarın Redis'te var olup olmadığını kontrol et"""
        try:
            redis_conn = await get_redis_client()
            result = await redis_conn.exists(key)
            await redis_conn.close()
            return result > 0
        except Exception as e:
            logging.error(f"Redis exists error: {e}")
            return False

# Redis bağlantı durumu
_redis_available = None

async def is_redis_available() -> bool:
    """Redis'in kullanılabilir olup olmadığını kontrol et"""
    global _redis_available
    if _redis_available is None:
        try:
            redis_conn = await get_redis_client()
            await redis_conn.ping()
            await redis_conn.close()
            _redis_available = True
        except Exception as e:
            logging.warning(f"Redis not available: {e}")
            _redis_available = False
    return _redis_available

class SessionManager:
    """Kullanıcı session yönetimi için sınıf"""
    
    @staticmethod
    async def set_session(user_id: int, session_data: Dict) -> bool:
        """Kullanıcı session'ını kaydet"""
        key = f"session:{user_id}"
        return await RedisCache.set_cache(key, session_data, expire=86400)  # 24 saat
    
    @staticmethod
    async def get_session(user_id: int) -> Optional[Dict]:
        """Kullanıcı session'ını oku"""
        key = f"session:{user_id}"
        return await RedisCache.get_cache(key)
    
    @staticmethod
    async def delete_session(user_id: int) -> bool:
        """Kullanıcı session'ını sil"""
        key = f"session:{user_id}"
        return await RedisCache.delete_cache(key)

class JWTBlacklist:
    """JWT token kara liste yönetimi"""
    
    @staticmethod
    async def add_to_blacklist(token: str, expire_time: int) -> bool:
        """JWT token'ı kara listeye ekle"""
        try:
            key = f"blacklist:{token}"
            return await RedisCache.set_cache(key, {"blacklisted": True}, expire=expire_time)
        except Exception as e:
            logging.error(f"JWT blacklist add error: {e}")
            return False
    
    @staticmethod
    async def is_blacklisted(token: str) -> bool:
        """Token'ın kara listede olup olmadığını kontrol et"""
        try:
            key = f"blacklist:{token}"
            return await RedisCache.exists_cache(key)
        except Exception as e:
            logging.error(f"JWT blacklist check error: {e}")
            return False  # Redis hatası durumunda false döndür (güvenlik için)

class RateLimiter:
    """API rate limiting için sınıf"""
    
    @staticmethod
    async def check_rate_limit(user_id: int, endpoint: str, limit: int = 100, window: int = 3600) -> bool:
        """Rate limit kontrolü"""
        key = f"rate_limit:{user_id}:{endpoint}"
        try:
            redis_conn = await get_redis_client()
            current = await redis_conn.get(key)
            
            if current is None:
                await redis_conn.setex(key, window, 1)
                await redis_conn.close()
                return True
            
            current_count = int(current)
            if current_count >= limit:
                await redis_conn.close()
                return False
            
            await redis_conn.incr(key)
            await redis_conn.close()
            return True
        except Exception as e:
            logging.error(f"Rate limit error: {e}")
            return True  # Hata durumunda erişime izin ver

# Redis bağlantı test fonksiyonu
async def test_redis_connection():
    """Redis bağlantısını test et"""
    try:
        redis_conn = await get_redis_client()
        await redis_conn.ping()
        await redis_conn.close()
        return True
    except Exception as e:
        logging.error(f"Redis connection test failed: {e}")
        return False 