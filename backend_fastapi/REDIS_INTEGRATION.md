# Redis Entegrasyonu

Bu projede Redis, önbellekleme ve session yönetimi için entegre edilmiştir.

## Özellikler

### 1. Listing Önbellekleme
- **Endpoint**: `GET /listings/{listing_id}`
- **Önbellek Anahtarı**: `listing:{listing_id}`
- **Süre**: 1 saat (3600 saniye)
- **İşleyiş**: 
  - İlk istek: Veritabanından veri çekilir ve Redis'e kaydedilir
  - Sonraki istekler: Redis'ten hızlıca alınır
  - Güncelleme/Silme: Önbellek otomatik temizlenir

### 2. JWT Token Kara Liste
- **Endpoint**: `POST /auth/logout`
- **Önbellek Anahtarı**: `blacklist:{token}`
- **Süre**: 24 saat (86400 saniye)
- **İşleyiş**: 
  - Logout sırasında token kara listeye eklenir
  - Her API isteğinde token kontrol edilir
  - Kara listedeki token'lar reddedilir

### 3. Session Yönetimi
- **Önbellek Anahtarı**: `session:{user_id}`
- **Süre**: 24 saat
- **Kullanım**: Kullanıcı session bilgilerini saklamak için

### 4. Rate Limiting
- **Önbellek Anahtarı**: `rate_limit:{user_id}:{endpoint}`
- **Varsayılan Limit**: 100 istek/saat
- **Kullanım**: API rate limiting için

## Test Endpoint'leri

### Redis Bağlantı Testi
```bash
GET /test-redis
```

### Cache Test
```bash
# Cache'e veri yaz
POST /test-cache

# Cache'den veri oku
GET /test-cache
```

## Kurulum

### 1. Redis Kurulumu (Docker ile)
```bash
# Docker Compose ile Redis başlat
docker-compose up -d redis

# Veya sadece Redis
docker run -d -p 6379:6379 redis
```

### 2. Python Bağımlılıkları
```bash
pip install redis aioredis
```

### 3. Ortam Değişkenleri
`.env` dosyasına ekleyin:
```env
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0
REDIS_PASSWORD=
```

## Kullanım Örnekleri

### Listing Önbellekleme
```python
# Listing detayı al
GET /listings/1

# İlk istek: Veritabanından alınır ve Redis'e kaydedilir
# Sonraki istekler: Redis'ten hızlıca alınır
```

### JWT Blacklist
```python
# Login
POST /auth/login/phone
# Response: {"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."}

# Logout (token'ı kara listeye ekler)
POST /auth/logout
# Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...

# Artık bu token ile yapılan istekler reddedilir
```

### Rate Limiting
```python
# Her endpoint için rate limit kontrolü
# Varsayılan: 100 istek/saat
# Limit aşılırsa 429 Too Many Requests döner
```

## Performans Avantajları

1. **Hızlı Erişim**: Redis'ten veri okuma çok hızlı
2. **Veritabanı Yükünü Azaltma**: Sık erişilen veriler Redis'te
3. **Ölçeklenebilirlik**: Birden fazla sunucu aynı Redis'i kullanabilir
4. **Güvenlik**: JWT token'ları güvenli şekilde iptal edilebilir

## Monitoring

Redis performansını izlemek için:
```bash
# Redis CLI
redis-cli

# Redis info
redis-cli info

# Redis memory usage
redis-cli info memory
```

## Hata Ayıklama

Redis bağlantı sorunları için:
1. Redis servisinin çalıştığını kontrol edin
2. Port 6379'un açık olduğunu kontrol edin
3. `/test-redis` endpoint'ini test edin
4. Logları kontrol edin 