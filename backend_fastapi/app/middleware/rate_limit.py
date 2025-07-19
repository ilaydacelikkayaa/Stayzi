from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
from app.utils.redis_client import RateLimiter, is_redis_available
import logging

async def rate_limit_middleware(request: Request, call_next):
    """Rate limiting middleware"""
    try:
        # Kullanıcı ID'sini al (eğer authenticate olmuşsa)
        user_id = None
        if hasattr(request.state, "user"):
            user_id = request.state.user.id
        else:
            # Anonim kullanıcılar için IP adresi kullan
            user_id = request.client.host
        
        # Endpoint'i al
        endpoint = f"{request.method}:{request.url.path}"
        
        # Rate limit kontrolü (Redis kullanılabilirse)
        if await is_redis_available():
            is_allowed = await RateLimiter.check_rate_limit(
                user_id=user_id,
                endpoint=endpoint,
                limit=100,  # 100 istek/saat
                window=3600  # 1 saat
            )
            
            if not is_allowed:
                return JSONResponse(
                    status_code=429,
                    content={
                        "detail": "Rate limit exceeded. Please try again later.",
                        "retry_after": 3600
                    }
                )
        else:
            # Redis kullanılamıyorsa rate limiting devre dışı
            logging.warning("Redis not available, rate limiting disabled")
        
        # İsteği devam ettir
        response = await call_next(request)
        return response
        
    except Exception as e:
        logging.error(f"Rate limit middleware error: {e}")
        # Hata durumunda isteği devam ettir
        return await call_next(request) 