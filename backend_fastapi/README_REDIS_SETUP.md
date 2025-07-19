# Redis Kurulum ve Çalıştırma Talimatları

Bu doküman, projenizde Redis entegrasyonunu nasıl kuracağınızı ve çalıştıracağınızı açıklar.

## 🚀 Hızlı Başlangıç

### 1. Redis Kurulumu (Docker ile - Önerilen)

```bash
# Redis'i Docker ile başlat
docker run -d -p 6379:6379 --name redis-stayzi redis

# Redis'in çalıştığını kontrol et
docker ps
```

### 2. Python Bağımlılıklarını Yükle

```bash
cd backend_fastapi
pip install -r requirements.txt
```

### 3. Backend'i Başlat

```bash
# Backend'i başlat
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 4. Redis Bağlantısını Test Et

```bash
# Test script'ini çalıştır
python test_redis.py
```

## 📋 Detaylı Kurulum

### Docker Compose ile (Tüm Servisler)

```bash
# Tüm servisleri başlat (PostgreSQL, Redis, RabbitMQ)
docker-compose up -d

# Sadece Redis'i başlat
docker-compose up -d redis
```

### Manuel Redis Kurulumu

#### Windows
```bash
# Chocolatey ile
choco install redis-64

# Veya WSL2 kullanarak
wsl --install Ubuntu
# Ubuntu'da Redis kurulumu
sudo apt update
sudo apt install redis-server
sudo systemctl start redis-server
```

#### macOS
```bash
# Homebrew ile
brew install redis
brew services start redis
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server
```

## 🔧 Konfigürasyon

### Ortam Değişkenleri

`.env` dosyası oluşturun:

```env
# Database
DATABASE_URL=postgresql://postgres:243a243a243@localhost:5432/stayzi_db

# JWT
SECRET_KEY=your-super-secret-key-here-make-it-long-and-random

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0
REDIS_PASSWORD=
```

### Redis Konfigürasyonu

Redis'i production için optimize etmek için:

```bash
# Redis CLI'ya bağlan
redis-cli

# Memory limit ayarla (512MB)
CONFIG SET maxmemory 512mb
CONFIG SET maxmemory-policy allkeys-lru

# Persistence ayarla
CONFIG SET save "900 1 300 10 60 10000"
```

## 🧪 Test Etme

### 1. Redis Bağlantı Testi

```bash
curl http://localhost:8000/test-redis
```

### 2. Cache Test

```bash
# Cache'e veri yaz
curl -X POST http://localhost:8000/test-cache

# Cache'den veri oku
curl http://localhost:8000/test-cache
```

### 3. Listing Önbellekleme Testi

```bash
# İlk istek (veritabanından)
curl http://localhost:8000/listings/1

# İkinci istek (Redis'ten - daha hızlı)
curl http://localhost:8000/listings/1
```

### 4. JWT Blacklist Testi

```bash
# Login
curl -X POST http://localhost:8000/auth/login/phone \
  -H "Content-Type: application/json" \
  -d '{"phone": "5551234567", "password": "test123"}'

# Logout (token'ı kara listeye ekler)
curl -X POST http://localhost:8000/auth/logout \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 📊 Monitoring

### Redis CLI ile Monitoring

```bash
# Redis CLI'ya bağlan
redis-cli

# Redis info
INFO

# Memory kullanımı
INFO memory

# Connected clients
INFO clients

# Slow queries
SLOWLOG GET 10
```

### Redis Desktop Manager

Redis Desktop Manager (RedisInsight) kullanarak görsel monitoring:

1. [RedisInsight](https://redis.com/redis-enterprise/redis-insight/) indirin
2. Redis bağlantısı ekleyin: `localhost:6379`
3. Real-time monitoring yapın

## 🐛 Hata Ayıklama

### Yaygın Sorunlar

#### 1. Redis Bağlantı Hatası
```
Error: Connection refused
```

**Çözüm:**
```bash
# Redis'in çalıştığını kontrol et
docker ps | grep redis
# veya
systemctl status redis
```

#### 2. Port 6379 Kullanımda
```
Error: Address already in use
```

**Çözüm:**
```bash
# Port'u kullanan process'i bul
netstat -tulpn | grep 6379
# Process'i sonlandır
kill -9 PID
```

#### 3. Memory Hatası
```
Error: OOM command not allowed when used memory > 'maxmemory'
```

**Çözüm:**
```bash
# Redis CLI'da memory limit artır
redis-cli
CONFIG SET maxmemory 1gb
```

### Debug Logları

```bash
# Redis loglarını izle
docker logs redis-stayzi -f

# Backend loglarını izle
uvicorn app.main:app --reload --log-level debug
```

## 🔒 Güvenlik

### Production Redis Ayarları

```bash
# Redis CLI'da güvenlik ayarları
redis-cli

# Şifre ayarla
CONFIG SET requirepass "güçlü-şifre-buraya"

# Bind address (sadece localhost)
CONFIG SET bind 127.0.0.1

# Protected mode
CONFIG SET protected-mode yes
```

### Firewall Ayarları

```bash
# Sadece gerekli port'ları aç
sudo ufw allow 6379/tcp
sudo ufw enable
```

## 📈 Performans Optimizasyonu

### Redis Memory Optimizasyonu

```bash
# Memory kullanımını optimize et
redis-cli

# LRU eviction policy
CONFIG SET maxmemory-policy allkeys-lru

# Memory limit
CONFIG SET maxmemory 512mb

# Compression
CONFIG SET rdbcompression yes
```

### Connection Pooling

Redis connection pooling için `aioredis` kullanıyoruz. Bu otomatik olarak connection pool yönetir.

## 🎯 Sonuç

Redis entegrasyonu tamamlandı! Şu özellikler aktif:

✅ **Listing Önbellekleme**: Sık erişilen listing'ler Redis'te saklanır  
✅ **JWT Blacklist**: Logout edilen token'lar güvenli şekilde iptal edilir  
✅ **Rate Limiting**: API rate limiting Redis ile yapılır  
✅ **Session Yönetimi**: Kullanıcı session'ları Redis'te saklanır  

Test etmek için: `python test_redis.py` 