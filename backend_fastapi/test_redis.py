#!/usr/bin/env python3
"""
Redis Entegrasyonu Test Script'i
Bu script Redis entegrasyonunun çalışıp çalışmadığını test eder.
"""

import asyncio
import aiohttp
import json
import time

BASE_URL = "http://10.0.2.2:8000"

async def test_redis_connection():
    """Redis bağlantısını test et"""
    print("🔍 Redis bağlantısı test ediliyor...")
    
    async with aiohttp.ClientSession() as session:
        async with session.get(f"{BASE_URL}/test-redis") as response:
            result = await response.json()
            print(f"Redis bağlantı testi: {result}")
            return result.get("success", False)

async def test_cache_operations():
    """Cache işlemlerini test et"""
    print("\n🔍 Cache işlemleri test ediliyor...")
    
    async with aiohttp.ClientSession() as session:
        # Cache'e veri yaz
        print("📝 Cache'e test verisi yazılıyor...")
        async with session.post(f"{BASE_URL}/test-cache") as response:
            result = await response.json()
            print(f"Cache yazma: {result}")
        
        # Cache'den veri oku
        print("📖 Cache'den test verisi okunuyor...")
        async with session.get(f"{BASE_URL}/test-cache") as response:
            result = await response.json()
            print(f"Cache okuma: {result}")
            
            if result.get("success") and result.get("data"):
                print("✅ Cache işlemleri başarılı!")
                return True
            else:
                print("❌ Cache işlemleri başarısız!")
                return False

async def test_listing_cache():
    """Listing önbellekleme test et"""
    print("\n🔍 Listing önbellekleme test ediliyor...")
    
    async with aiohttp.ClientSession() as session:
        # İlk istek (veritabanından alınacak)
        print("📝 İlk istek - veritabanından alınacak...")
        start_time = time.time()
        async with session.get(f"{BASE_URL}/listings/1") as response:
            first_response_time = time.time() - start_time
            print(f"İlk istek süresi: {first_response_time:.3f} saniye")
        
        # İkinci istek (Redis'ten alınacak)
        print("📖 İkinci istek - Redis'ten alınacak...")
        start_time = time.time()
        async with session.get(f"{BASE_URL}/listings/1") as response:
            second_response_time = time.time() - start_time
            print(f"İkinci istek süresi: {second_response_time:.3f} saniye")
        
        # Performans karşılaştırması
        if second_response_time < first_response_time:
            print(f"✅ Redis önbellekleme çalışıyor! Hızlanma: {first_response_time/second_response_time:.2f}x")
            return True
        else:
            print("❌ Redis önbellekleme çalışmıyor!")
            return False

async def test_auth_endpoints():
    """Auth endpoint'lerini test et"""
    print("\n🔍 Auth endpoint'leri test ediliyor...")
    
    async with aiohttp.ClientSession() as session:
        # Login endpoint'ini test et
        print("🔐 Login endpoint test ediliyor...")
        login_data = {
            "phone": "5551234567",
            "password": "test123"
        }
        
        async with session.post(f"{BASE_URL}/auth/login/phone", json=login_data) as response:
            if response.status == 200:
                result = await response.json()
                token = result.get("access_token")
                print("✅ Login başarılı!")
                
                # Logout endpoint'ini test et
                print("🚪 Logout endpoint test ediliyor...")
                headers = {"Authorization": f"Bearer {token}"}
                async with session.post(f"{BASE_URL}/auth/logout", headers=headers) as logout_response:
                    if logout_response.status == 200:
                        print("✅ Logout başarılı!")
                        return True
                    else:
                        print("❌ Logout başarısız!")
                        return False
            else:
                print("❌ Login başarısız!")
                return False

async def test_rate_limiting():
    """Rate limiting test et"""
    print("\n🔍 Rate limiting test ediliyor...")
    
    async with aiohttp.ClientSession() as session:
        # Çok sayıda istek gönder
        print("📊 Rate limiting test ediliyor (100 istek)...")
        
        start_time = time.time()
        responses = []
        
        for i in range(100):
            async with session.get(f"{BASE_URL}/test-redis") as response:
                responses.append(response.status)
        
        end_time = time.time()
        total_time = end_time - start_time
        
        # 429 (Too Many Requests) var mı kontrol et
        rate_limited = any(status == 429 for status in responses)
        
        if rate_limited:
            print("✅ Rate limiting çalışıyor!")
        else:
            print("⚠️ Rate limiting test edilemedi (limit aşılmadı)")
        
        print(f"100 istek süresi: {total_time:.3f} saniye")
        return True

async def main():
    """Ana test fonksiyonu"""
    print("🚀 Redis Entegrasyonu Test Script'i Başlatılıyor...")
    print("=" * 50)
    
    tests = [
        ("Redis Bağlantısı", test_redis_connection),
        ("Cache İşlemleri", test_cache_operations),
        ("Listing Önbellekleme", test_listing_cache),
        ("Auth Endpoint'leri", test_auth_endpoints),
        ("Rate Limiting", test_rate_limiting),
    ]
    
    results = []
    
    for test_name, test_func in tests:
        try:
            print(f"\n{'='*20} {test_name} {'='*20}")
            result = await test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"❌ {test_name} test hatası: {e}")
            results.append((test_name, False))
    
    # Sonuçları özetle
    print("\n" + "=" * 50)
    print("📊 TEST SONUÇLARI")
    print("=" * 50)
    
    passed = 0
    total = len(results)
    
    for test_name, result in results:
        status = "✅ BAŞARILI" if result else "❌ BAŞARISIZ"
        print(f"{test_name}: {status}")
        if result:
            passed += 1
    
    print(f"\nToplam: {passed}/{total} test başarılı")
    
    if passed == total:
        print("🎉 Tüm testler başarılı! Redis entegrasyonu çalışıyor.")
    else:
        print("⚠️ Bazı testler başarısız. Redis ayarlarını kontrol edin.")

if __name__ == "__main__":
    asyncio.run(main()) 