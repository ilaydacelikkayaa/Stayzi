# API Services Documentation

Bu klasör, Flutter uygulamasının FastAPI backend'i ile iletişim kurması için gerekli tüm servisleri içerir.

## Dosya Yapısı

```
lib/services/
├── api_constants.dart      # API endpoint'leri ve sabitler
├── api_service.dart        # Ana API servis sınıfı
├── api_response.dart       # API yanıt wrapper'ı
├── storage_service.dart    # Token ve kullanıcı verisi saklama
├── example_usage.dart      # Kullanım örnekleri
└── README.md              

lib/models/
├── user_model.dart         # Kullanıcı model sınıfları
├── listing_model.dart      # İlan model sınıfları
├── auth_model.dart         # Kimlik doğrulama model sınıfları
└── favorite_model.dart     # Favori model sınıfları
```

## Kurulum

1. `pubspec.yaml` dosyasına gerekli bağımlılıkları ekleyin:

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

2. Bağımlılıkları yükleyin:

```bash
flutter pub get
```

## Kullanım

### 1. API Servisini Başlatma

```dart
import 'package:stayzi_ui/services/api_service.dart';
import 'package:stayzi_ui/services/storage_service.dart';

final apiService = ApiService();
final storageService = StorageService();
```

### 2. Kimlik Doğrulama

#### Email ile Giriş
```dart
try {
  final token = await apiService.loginWithEmail('user@example.com', 'password123');
  await storageService.saveToken(token);
  apiService.setAuthToken(token.accessToken);
  print('Giriş başarılı!');
} catch (e) {
  print('Giriş başarısız: $e');
}
```

#### Telefon ile Giriş
```dart
try {
  final token = await apiService.loginWithPhone('+1234567890', 'password123');
  await storageService.saveToken(token);
  apiService.setAuthToken(token.accessToken);
  print('Giriş başarılı!');
} catch (e) {
  print('Giriş başarısız: $e');
}
```

#### Kayıt Olma
```dart
import 'package:stayzi_ui/models/user_model.dart';

final userData = UserCreate(
  email: 'newuser@example.com',
  name: 'John',
  surname: 'Doe',
  birthdate: DateTime(1990, 1, 1),
  phone: '+1234567890',
  country: 'Turkey',
  profileImage: 'default.jpg',
  password: 'password123',
);

try {
  final user = await apiService.registerWithEmail(userData);
  print('Kullanıcı kaydedildi: ${user.name} ${user.surname}');
} catch (e) {
  print('Kayıt başarısız: $e');
}
```

### 3. Kullanıcı Profili

#### Profil Bilgilerini Getirme
```dart
try {
  final user = await apiService.getCurrentUser();
  print('Kullanıcı: ${user.name} ${user.surname}');
  print('Email: ${user.email}');
} catch (e) {
  print('Profil getirilemedi: $e');
}
```

#### Profil Güncelleme
```dart
try {
  final updatedUser = await apiService.updateProfile(
    name: 'Yeni İsim',
    surname: 'Yeni Soyisim',
    country: 'Türkiye',
  );
  print('Profil güncellendi: ${updatedUser.name}');
} catch (e) {
  print('Profil güncellenemedi: $e');
}
```

### 4. İlanlar

#### Tüm İlanları Getirme
```dart
try {
  final listings = await apiService.getListings(limit: 10);
  print('${listings.length} ilan bulundu');
  
  for (final listing in listings) {
    print('İlan: ${listing.title} - \$${listing.price}');
  }
} catch (e) {
  print('İlanlar getirilemedi: $e');
}
```

#### İlan Oluşturma
```dart
import 'package:stayzi_ui/models/listing_model.dart';

final listingData = ListingCreate(
  title: 'Güzel Daire',
  description: 'Şehir merkezinde rahat bir daire',
  price: 150.0,
  location: 'İstanbul, Türkiye',
  lat: 41.0082,
  lng: 28.9784,
  homeType: 'Daire',
  hostLanguages: ['Türkçe', 'İngilizce'],
  imageUrls: ['resim1.jpg', 'resim2.jpg'],
  homeRules: 'Sigara yok, evcil hayvan yok',
);

try {
  final listing = await apiService.createListing(listingData);
  print('İlan oluşturuldu: ${listing.title}');
} catch (e) {
  print('İlan oluşturulamadı: $e');
}
```

#### İlan Detayı Getirme
```dart
try {
  final listing = await apiService.getListingById(1);
  print('İlan detayı: ${listing.title}');
  print('Fiyat: \$${listing.price}');
  print('Konum: ${listing.location}');
} catch (e) {
  print('İlan detayı getirilemedi: $e');
}
```

### 5. Favoriler

#### Kullanıcının Favorilerini Getirme
```dart
import 'package:stayzi_ui/models/favorite_model.dart';

try {
  final favorites = await apiService.getMyFavorites(limit: 10);
  print('${favorites.length} favori bulundu');
  
  for (final favorite in favorites) {
    print('Favori ID: ${favorite.id}, User ID: ${favorite.userId}');
  }
} catch (e) {
  print('Favoriler getirilemedi: $e');
}
```

#### Favori Oluşturma
```dart
import 'package:stayzi_ui/models/favorite_model.dart';

final favoriteData = FavoriteCreate(userId: 1);

try {
  final favorite = await apiService.createFavorite(favoriteData);
  print('Favori oluşturuldu: ID ${favorite.id}');
} catch (e) {
  print('Favori oluşturulamadı: $e');
}
```

### 6. Veri Saklama

#### Token Saklama ve Alma
```dart
// Token saklama
await storageService.saveToken(token);

// Token alma
final token = await storageService.getToken();
final accessToken = await storageService.getAccessToken();

// Kullanıcı bilgisi saklama
await storageService.saveUser(user);

// Kullanıcı bilgisi alma
final user = await storageService.getUser();
```

#### Giriş Durumu Kontrolü
```dart
final isLoggedIn = await storageService.isLoggedIn();
if (isLoggedIn) {
  // Kullanıcı giriş yapmış
} else {
  // Kullanıcı giriş yapmamış
}
```

#### Çıkış Yapma
```dart
await storageService.logout();
apiService.clearAuthToken();
```

### 7. Bağlantı Testi

```dart
try {
  // API bağlantı testi
  final result = await apiService.testConnection();
  print('API bağlantı testi: $result');

  // Veritabanı bağlantı testi
  final dbResult = await apiService.testDatabase();
  print('Veritabanı testi: $dbResult');
} catch (e) {
  print('Bağlantı testi başarısız: $e');
}
```

## API Endpoint'leri

### Kimlik Doğrulama
- `POST /auth/login/email` - Email ile giriş
- `POST /auth/login/phone` - Telefon ile giriş
- `POST /auth/register/email` - Email ile kayıt
- `POST /auth/register/phone` - Telefon ile kayıt

### Kullanıcı
- `GET /users/me` - Mevcut kullanıcı profili
- `PUT /users/me` - Profil güncelleme
- `GET /users/` - Tüm kullanıcılar (admin)
- `GET /users/id/{id}` - ID ile kullanıcı getirme
- `DELETE /users/me` - Hesap deaktive etme

### İlanlar
- `GET /listings/` - Tüm ilanlar
- `GET /listings/{id}` - ID ile ilan getirme
- `POST /listings/` - İlan oluşturma
- `PUT /listings/{id}` - İlan güncelleme
- `DELETE /listings/{id}` - İlan silme

### Favoriler
- `POST /favorites/` - Favori oluşturma
- `GET /favorites/my-favorites` - Kullanıcının favorilerini getirme

## Hata Yönetimi

Tüm API çağrıları try-catch blokları ile sarmalanmalıdır:

```dart
try {
  final result = await apiService.someMethod();
  // Başarılı işlem
} catch (e) {
  // Hata yönetimi
  print('Hata: $e');
  // Kullanıcıya hata mesajı göster
}
```

## Notlar

1. **Base URL**: `api_constants.dart` dosyasında base URL'i cihazınıza göre ayarlayın:
   - Android Emulator: `http://10.0.2.2:8000`
   - iOS Simulator: `http://localhost:8000`
   - Fiziksel cihaz: `http://your-server-ip:8000`

2. **Token Yönetimi**: Token'lar otomatik olarak API servisinde saklanır ve gerektiğinde header'lara eklenir.

3. **Dosya Yükleme**: Profil resmi güncelleme için `File` objesi kullanılır.

4. **Bağımlılıklar**: `http` ve `shared_preferences` paketleri gerekli olup `pubspec.yaml`'a eklenmelidir. 