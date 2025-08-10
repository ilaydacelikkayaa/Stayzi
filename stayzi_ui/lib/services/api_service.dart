import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stayzi_ui/models/booking_model.dart';
import 'package:stayzi_ui/models/review_model.dart';
import 'package:stayzi_ui/services/storage_service.dart';

//import 'package:stayzi_ui/screens/detail/review_detail_page.dart';

import '../models/auth_model.dart';
import '../models/favorite_model.dart';
import '../models/listing_model.dart';
import '../models/user_model.dart';
import 'api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  // Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
    print("🔐 Token kaydedildi: $_authToken");
  }

  // Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  // Get headers with or without authentication
  Map<String, String> _getHeaders({bool requiresAuth = false}) {
    if (requiresAuth && _authToken != null) {
      print("🔐 Token mevcut: ${_authToken!.substring(0, 20)}...");
      print("📤 Giden header'lar: ${ApiConstants.authHeaders(_authToken!)}");
      return ApiConstants.authHeaders(_authToken!);
    } else if (requiresAuth && _authToken == null) {
      print("❌ Token gerekli ama mevcut değil!");
      throw Exception('Authentication token required but not available');
    }
    print("📤 Giden header'lar (auth olmadan): ${ApiConstants.defaultHeaders}");
    return ApiConstants.defaultHeaders;
  }

  // Debug method to check token status
  void debugTokenStatus() {
    print("🔍 Token durumu:");
    print("   Token var mı: ${_authToken != null}");
    if (_authToken != null) {
      print("   Token uzunluğu: ${_authToken!.length}");
      print("   Token başlangıcı: ${_authToken!.substring(0, 20)}...");
    }
  }

  // Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    print("DEBUG: _handleResponse çağrıldı, body: ${response.body}");
    final data = json.decode(response.body);
    if (data is Map && data['detail'] != null) {
      throw Exception(data['detail']);
    }
    if (data is Map || data is List) {
      return data;
    }
    throw Exception('Beklenmeyen response tipi: ${data.runtimeType}');
  }

  // Test connection
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.testRoot}'),
        headers: _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Connection test failed: $e');
    }
  }

  // Test database connection
  Future<Map<String, dynamic>> testDatabase() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.testDb}'),
        headers: _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Database test failed: $e');
    }
  }

  // ========== AUTHENTICATION ENDPOINTS ==========

  // Login with email
  Future<Token> loginWithEmail(String email, String password) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.loginEmail}';
      print("📡 Login URL: $url");

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login/email'),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"username": email, "password": password},
      );

      print("📥 Status Code: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      final data = _handleResponse(response);
      return Token.fromJson(data);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Login with phone (şifresiz)
  Future<Token> loginWithPhone(String phone, [String? password]) async {
    try {
      print("📲 Telefon ile giriş deneniyor: $phone");

      final body =
          password != null
              ? jsonEncode({'phone': phone, 'password': password})
              : jsonEncode({'phone': phone});

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginPhone}'),
        headers: _getHeaders(), // ✅ Doğru header'ları kullan
        body: body,
      );

      print("📲 Response status: ${response.statusCode}");
      print("📲 Response body: ${response.body}");

      final data = _handleResponse(response);
      final token = Token.fromJson(data);
      setAuthToken(token.accessToken);

      print("📲 Giriş yapan kullanıcının token'ı: ${token.accessToken}");

      return token; // ✅ Token'ı tekrar oluşturma
    } catch (e) {
      print("❌ Telefon ile giriş hatası: $e");
      throw Exception('Phone login failed: $e');
    }
  }

  // Register with email
  Future<User> registerWithEmail(UserCreate userData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEmail}'),
        headers: _getHeaders(),
        body: json.encode(userData.toJson()),
      );
      final data = _handleResponse(response);
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Register with phone
  Future<Map<String, dynamic>> registerWithPhone(PhoneRegister userData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerPhone}'),
        headers: _getHeaders(),
        body: json.encode(userData.toJson()),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Phone registration failed: $e');
    }
  }

  // ========== USER ENDPOINTS ==========

  // Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userProfile}'),
        headers: _getHeaders(requiresAuth: true),
      );
      final data = _handleResponse(response);
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  Future<User> updateProfile({
    String? name,
    String? surname,
    String? email,
    String? phone,
    DateTime? birthdate,
    String? country,
    File? profileImage,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateProfile}'),
      );

      // Add headers
      request.headers.addAll(_getHeaders(requiresAuth: true));

      // Add form fields (sadece boş olmayan değerleri gönder)
      if (name != null && name.trim().isNotEmpty)
        request.fields['name'] = name.trim();
      if (surname != null && surname.trim().isNotEmpty)
        request.fields['surname'] = surname.trim();
      if (email != null && email.trim().isNotEmpty)
        request.fields['email'] = email.trim();
      if (phone != null && phone.trim().isNotEmpty)
        request.fields['phone'] = phone.trim();
      if (birthdate != null) {
        request.fields['birthdate'] = birthdate.toIso8601String().split('T')[0];
      }
      if (country != null && country.trim().isNotEmpty)
        request.fields['country'] = country.trim();

      // Add profile image if provided
      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', profileImage.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = _handleResponse(response);
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get all users (admin only)
  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.allUsers}'),
        headers: _getHeaders(requiresAuth: true),
      );
      final data = _handleResponse(response);
      return (data as List).map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // Get user by ID
  Future<User> getUserById(int userId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.userById}$userId/with-host',
        ),
        headers: _getHeaders(requiresAuth: true),
      );
      final data = _handleResponse(response);
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Deactivate (disable) current user account
  Future<void> deactivateAccount() async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deactivateAccount}'),
        headers: _getHeaders(requiresAuth: true),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Hesap devre dışı bırakılamadı: ${response.body}');
      }
    } catch (e) {
      throw Exception('Hesap devre dışı bırakılırken hata: $e');
    }
  }

  // ========== LISTING ENDPOINTS ==========

  // Get all listings
  Future<List<Listing>> getListings({int skip = 0, int limit = 100}) async {
    try {
      print("🔍 getListings çağrıldı");
      print("🔍 _authToken = $_authToken");

      final headers = _getHeaders(requiresAuth: true);
      print("🔍 Headers: $headers");

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.listings}?skip=$skip&limit=$limit',
        ),
        headers: headers, // ✅ Token gönder
      );
      final data = _handleResponse(response);
      return (data as List).map((json) => Listing.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get listings: $e');
    }
  }

  // Get listing by ID
  Future<Listing> getListingById(int listingId) async {
    try {
      print("🔍 getListingById çağrıldı: ID=$listingId");
      
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.listingById}$listingId',
        ),
        headers: _getHeaders(),
      );
      
      print("🔍 Response status: ${response.statusCode}");
      print("🔍 Response body: ${response.body}");
      
      final data = _handleResponse(response);
      print("🔍 Parsed data: $data");

      final listing = Listing.fromJson(data);
      print("🔍 Listing amenities: ${listing.amenities}");

      return listing;
    } catch (e) {
      print("❌ getListingById hatası: $e");
      throw Exception('Failed to get listing: $e');
    }
  }

  Future<Listing> getListingWithHostById(int listingId) async {
    try {
      print("🏠 getListingWithHostById çağrıldı: ID=$listingId");

      final headers = _getHeaders(requiresAuth: true);
      print("🏠 Headers: $headers");

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/listings/$listingId/with-host'),
        headers: headers,
      );

      print("🏠 Response status: ${response.statusCode}");
      print("🏠 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("🏠 Parsed data: $data");
        return Listing.fromJson(data);
      } else {
        throw Exception(
          'İlan ve ev sahibi bilgisi alınamadı: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print("❌ getListingWithHostById hatası: $e");
      throw Exception('İlan ve ev sahibi bilgisi alınamadı: $e');
    }
  }

  // Delete listing
  Future<void> deleteListing(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deleteListing}$id'),
        headers: _getHeaders(requiresAuth: true),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('İlan silinemedi: ${response.body}');
      }
    } catch (e) {
      throw Exception('İlan silinirken hata: $e');
    }
  }

  // Add new listing
  Future<void> addListing({
    required String title,
    required String location,
    required String price,
    File? image,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createListing}'),
      );
      request.headers.addAll(_getHeaders(requiresAuth: true));
      request.fields['title'] = title;
      request.fields['location'] = location;
      request.fields['price'] = price;
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', image.path),
        );
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('İlan eklenemedi: ${response.body}');
      }
    } catch (e) {
      throw Exception('İlan eklenirken hata: $e');
    }
  }

  // ========== FAVORITE ENDPOINTS ==========

  // Get my favorites
  Future<List<Favorite>> getMyFavorites({int skip = 0, int limit = 100}) async {
    try {
      print("🔍 getMyFavorites çağrıldı");

      // ✅ Token'ı direkt storage'dan al
      final Token? token = await StorageService().getToken();
      if (token == null) {
        throw Exception("Giriş yapmanız gerekiyor. Token bulunamadı.");
      }

      final headers = {
        'Authorization': 'Bearer ${token.accessToken}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.myFavorites}?skip=$skip&limit=$limit',
        ),
        headers: headers,
      );

      print("🔍 Response status: ${response.statusCode}");
      print("🔍 Response body: ${response.body}");

      final data = _handleResponse(response);
      return (data as List).map((json) => Favorite.fromJson(json)).toList();
    } catch (e) {
      print("❌ getMyFavorites error: $e");
      throw Exception('Favoriler alınamadı: $e');
    }
  }

  // Create new favorite
  Future<Favorite> createFavorite(FavoriteCreate favoriteData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createFavorite}'),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode(favoriteData.toJson()),
      );
      final data = _handleResponse(response);
      return Favorite.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create favorite: $e');
    }
  }

  // Delete favorite
  Future<void> deleteFavorite(int favoriteId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.deleteFavorite}$favoriteId',
        ),
        headers: _getHeaders(requiresAuth: true),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Favori silinemedi: ${response.body}');
      }
    } catch (e) {
      throw Exception('Favori silinirken hata: $e');
    }
  }

  // Check if listing is in favorites
  Future<bool> isFavorite(int listingId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.checkFavorite}$listingId',
        ),
        headers: _getHeaders(requiresAuth: true),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['is_favorite'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Toggle favorite (add/remove)
  Future<bool> toggleFavorite(int listingId) async {
    try {
      final isCurrentlyFavorite = await isFavorite(listingId);

      if (isCurrentlyFavorite) {
        // Remove from favorites
        final response = await http.delete(
          Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.deleteFavorite}$listingId',
          ),
          headers: _getHeaders(requiresAuth: true),
        );
        return response.statusCode >= 200 && response.statusCode < 300;
      } else {
        // Add to favorites
        final favoriteData = FavoriteCreate(listingId: listingId);
        await createFavorite(favoriteData);
        return true;
      }
    } catch (e) {
      throw Exception('Favori işlemi başarısız: $e');
    }
  }

  // ========== USER LISTINGS ENDPOINTS ==========

  // Get user's own listings
  Future<List<Listing>> getMyListings() async {
    try {
      print("getMyListings çağrıldı");

      final Token? token = await StorageService().getToken();
      if (token == null) {
        throw Exception("Token bulunamadı. Giriş yapmanız gerekiyor.");
      }

      final headers = {
        'Authorization': 'Bearer ${token.accessToken}',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/listings/my-listings'),
        headers: headers,
      );

      print('getMyListings response status: ${response.statusCode}');
      print('getMyListings response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Listing.fromJson(json)).toList();
      } else {
        throw Exception('İlanlar yüklenemedi');
      }
    } catch (e) {
      print("❌ getMyListings error: $e");
      throw Exception('getMyListings hata: $e');
    }
  }

  // Get user's listings by user ID
  Future<List<Listing>> getUserListings(
    int userId, {
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.userListings}?user_id=$userId&skip=$skip&limit=$limit',
        ),
        headers: _getHeaders(requiresAuth: true),
      );
      final data = _handleResponse(response);
      return (data as List).map((json) => Listing.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Kullanıcı ilanları alınamadı: $e');
    }
  }

  // ========== LISTING IMAGES ENDPOINTS ==========

  // Upload listing image
  // Upload listing image
  Future<String> uploadListingImage(int listingId, File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.listingImages}$listingId/images',
        ),
      );

      request.headers.addAll(_getHeaders(requiresAuth: true));
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = _handleResponse(response);

      // ✅ Gelen cevabı kontrol et
      print("📸 uploadListingImage response: $data");
      print("✅ image_url: ${data['image_url']}");

      return data['image_url'] ?? '';
    } catch (e) {
      throw Exception('İlan fotoğrafı yüklenemedi: $e');
    }
  }

  // Delete listing image
  Future<void> deleteListingImage(int listingId, String imageUrl) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.listingImages}$listingId/images',
        ),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode({'image_url': imageUrl}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('İlan fotoğrafı silinemedi: ${response.body}');
      }
    } catch (e) {
      throw Exception('İlan fotoğrafı silinirken hata: $e');
    }
  }

  // ========== ENHANCED LISTING ENDPOINTS ==========

  // Create listing with photo
  Future<Listing> createListing({
    required String title,
    String? description,
    String? location,
    double? lat,
    double? lng,
    required double price,
    String? homeType,
    List<String>? hostLanguages,
    String? homeRules,
    int? capacity,
    List<Map<String, dynamic>>? amenities,
    File? photo,
    bool? allowEvents,
    bool? allowSmoking,
    bool? allowCommercialPhoto,
    int? maxGuests,
    int? roomCount,
    int? bedCount,
    int? bathroomCount,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createListing}'),
      );

      request.headers.addAll(_getHeaders(requiresAuth: true));
      request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;
      if (location != null) request.fields['location'] = location;
      if (lat != null) request.fields['lat'] = lat.toString();
      if (lng != null) request.fields['lng'] = lng.toString();
      request.fields['price'] = price.toString();
      if (homeType != null) request.fields['home_type'] = homeType;
      if (homeRules != null) request.fields['home_rules'] = homeRules;
      if (capacity != null) request.fields['capacity'] = capacity.toString();
      if (allowEvents != null)
        request.fields['allow_events'] = (allowEvents ? 1 : 0).toString();
      if (allowSmoking != null)
        request.fields['allow_smoking'] = (allowSmoking ? 1 : 0).toString();
      if (allowCommercialPhoto != null)
        request.fields['allow_commercial_photo'] =
            (allowCommercialPhoto ? 1 : 0).toString();
      if (maxGuests != null)
        request.fields['max_guests'] = maxGuests.toString();
      if (roomCount != null)
        request.fields['room_count'] = roomCount.toString();
      if (bedCount != null) request.fields['bed_count'] = bedCount.toString();
      if (bathroomCount != null)
        request.fields['bathroom_count'] = bathroomCount.toString();

      if (hostLanguages != null) {
        request.fields['host_languages'] = json.encode(hostLanguages);
      }

      if (amenities != null) {
        final serializedAmenities =
            amenities.map((a) => {"id": a["id"], "name": a["name"]}).toList();
        request.fields['amenities'] = json.encode(serializedAmenities);
      }

      if (photo != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', photo.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = _handleResponse(response);
      return Listing.fromJson(data);
    } catch (e) {
      throw Exception('İlan oluşturulamadı: $e');
    }
  }

  // Update listing with photos
  Future<Listing> updateListing({
    required int listingId,
    String? title,
    String? description,
    String? location,
    double? lat,
    double? lng,
    double? price,
    String? homeType,
    List<String>? hostLanguages,
    String? homeRules,
    int? capacity,
    List<Map<String, dynamic>>? amenities,
    File? photo,
    List<File>? photos,
    int? roomCount,
    int? bedCount,
    int? bathroomCount,
    bool? allowEvents,
    bool? allowSmoking,
    bool? allowCommercialPhoto,
    int? maxGuests,
  }) async {
    try {
      print('DEBUG - Flutter UpdateListing: Başlıyor...');
      print('DEBUG - Flutter UpdateListing: listingId = $listingId');
      print('DEBUG - Flutter UpdateListing: amenities = $amenities');

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.updateListing}$listingId',
        ),
      );

      request.headers.addAll(_getHeaders(requiresAuth: true));
      if (title != null) request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;
      if (location != null) request.fields['location'] = location;
      if (lat != null) request.fields['lat'] = lat.toString();
      if (lng != null) request.fields['lng'] = lng.toString();
      if (price != null) request.fields['price'] = price.toString();
      if (homeType != null) request.fields['home_type'] = homeType;
      if (homeRules != null) request.fields['home_rules'] = homeRules;
      if (capacity != null) request.fields['capacity'] = capacity.toString();
      if (roomCount != null)
        request.fields['room_count'] = roomCount.toString();
      if (bedCount != null) request.fields['bed_count'] = bedCount.toString();
      if (bathroomCount != null)
        request.fields['bathroom_count'] = bathroomCount.toString();
      if (allowEvents != null)
        request.fields['allow_events'] = (allowEvents ? 1 : 0).toString();
      if (allowSmoking != null)
        request.fields['allow_smoking'] = (allowSmoking ? 1 : 0).toString();
      if (allowCommercialPhoto != null)
        request.fields['allow_commercial_photo'] =
            (allowCommercialPhoto ? 1 : 0).toString();
      if (maxGuests != null)
        request.fields['max_guests'] = maxGuests.toString();

      if (hostLanguages != null) {
        request.fields['host_languages'] = json.encode(hostLanguages);
      }

      if (amenities != null) {
        request.fields['amenities'] = json.encode(amenities);
        print(
          'DEBUG - Flutter UpdateListing: amenities JSON = ${json.encode(amenities)}',
        );
      }

      // Fotoğrafları ekle
      if (photos != null && photos.isNotEmpty) {
        print(
          'DEBUG - Flutter UpdateListing: ${photos.length} adet fotoğraf ekleniyor...',
        );
        for (int i = 0; i < photos.length; i++) {
          final photo = photos[i];
          final fieldName = 'photos[$i]'; // Backend'de array olarak alınacak
          request.files.add(
            await http.MultipartFile.fromPath(fieldName, photo.path),
          );
          print(
            'DEBUG - Flutter UpdateListing: Fotoğraf ${i + 1} eklendi: ${photo.path}',
          );
        }
      } else if (photo != null) {
        // Tek fotoğraf için geriye dönük uyumluluk
        print('DEBUG - Flutter UpdateListing: Tek fotoğraf ekleniyor...');
        request.files.add(
          await http.MultipartFile.fromPath('photo', photo.path),
        );
      } else {
        print('DEBUG - Flutter UpdateListing: Fotoğraf eklenmedi');
      }

      print(
        'DEBUG - Flutter UpdateListing: Request fields = ${request.fields}',
      );
      print('DEBUG - Flutter UpdateListing: Request URL = ${request.url}');
      print(
        'DEBUG - Flutter UpdateListing: Request headers = ${request.headers}',
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print(
        'DEBUG - Flutter UpdateListing: Response status = ${response.statusCode}',
      );
      print('DEBUG - Flutter UpdateListing: Response body = ${response.body}');

      final data = _handleResponse(response);
      return Listing.fromJson(data);
    } catch (e) {
      print('DEBUG - Flutter UpdateListing: Error = $e');
      throw Exception('İlan güncellenemedi: $e');
    }
  }

  // ========== BOOKING ENDPOINTS ==========

  // Create a new booking
  Future<Booking> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/bookings/'),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode(bookingData),
      );
      final data = _handleResponse(response);
      return Booking.fromJson(data);
    } catch (e) {
      throw Exception('Booking oluşturulamadı: $e');
    }
  }

  // ========== REVIEW ENDPOINTS ==========

  // Get reviews for a listing
  Future<List<Map<String, dynamic>>> getListingReviews(int listingId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/reviews/listing/$listingId'),
        headers: _getHeaders(),
      );
      final data = _handleResponse(response);
      return (data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Review yükleme hatası: $e');
      return []; // Hata durumunda boş liste döndür
    }
  }

  // Create a review
  Future<Map<String, dynamic>> createReview({
    required int listingId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/reviews/'),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode({
          'listing_id': listingId,
          'rating': rating,
          'comment': comment,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Review oluşturulamadı: $e');
    }
  }

  // ========== SEARCH AND FILTER ENDPOINTS ==========

  // Search listings by query
  Future<List<Listing>> searchListings(
    String query, {
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.listings}search?q=${Uri.encodeComponent(query)}&skip=$skip&limit=$limit',
        ),
        headers: _getHeaders(),
      );
      final data = _handleResponse(response);
      return (data as List).map((json) => Listing.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Arama sonuçları alınamadı: $e');
    }
  }

  // Get listings by location
  Future<List<Listing>> getListingsByLocation(
    String location, {
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.listings}location/${Uri.encodeComponent(location)}?skip=$skip&limit=$limit',
        ),
        headers: _getHeaders(),
      );
      final data = _handleResponse(response);
      return (data as List).map((json) => Listing.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Konum bazlı ilanlar alınamadı: $e');
    }
  }

  // ========== UTILITY FUNCTIONS ==========

  // Check if phone number exists
  Future<bool> checkPhoneExists(String phone) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/users/phone-exists/$phone'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['exists'] == true;
    } else {
      throw Exception("Telefon kontrolü başarısız");
    }
  }

  // Check if email exists
  Future<bool> checkEmailExists(String email) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/users/email-exists/$email'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['exists'] == true;
    } else {
      throw Exception("Email kontrolü başarısız");
    }
  }

  // Fetch filtered listings
  Future<List<Listing>> fetchFilteredListings(
    Map<String, dynamic> filters,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/filter'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(filters),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Listing.fromJson(json)).toList();
    } else {
      throw Exception('Filtrelenmiş ilanlar alınamadı');
    }
  }

  // Fetch reviews for a listing
  Future<List<Review>> fetchReviews(int listingId) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/reviews/listing/$listingId',
      );
      final headers = _getHeaders(requiresAuth: true);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final reviews = jsonList.map((item) => Review.fromJson(item)).toList();
        print("✅ ${reviews.length} yorum başarıyla alındı.");
        return reviews;
      } else {
        print(
          "❌ Yorumlar alınamadı: ${response.statusCode} - ${response.body}",
        );
        throw Exception('Yorumlar alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Yorumlar alınırken hata oluştu: $e");
      throw Exception('Yorumlar alınırken hata oluştu: $e');
    }
  }

  Future<bool> postReview({
    required int listingId,
    required double rating,
    required String comment,
  }) async {
    final token = await StorageService().getToken();
    if (token == null || token.accessToken.isEmpty) {
      debugPrint("❌ Token bulunamadı, yorum gönderilemez.");
      return false;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/reviews/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token.accessToken}',
    };
    final body = jsonEncode({
      "listing_id": listingId,
      "rating": rating,
      "comment": comment,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      debugPrint(
        "📨 postReview yanıtı: ${response.statusCode} - ${response.body}",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("🚨 postReview hatası: $e");
      return false;
    }
  }

  /// Standardizes phone number format by combining country code and phone number
  /// Example: country="+90", phone="5551234567" -> "+905551234567"
  static String standardizePhoneNumber(String country, String phone) {
    // Remove any non-digit characters from phone number
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Remove any non-digit characters from country code
    String cleanCountry = country.replaceAll(RegExp(r'[^\d]'), '');

    // If country code doesn't start with +, add it
    if (!country.startsWith('+')) {
      cleanCountry = '+$cleanCountry';
    } else {
      cleanCountry = country;
    }

    // Combine country code and phone number
    return '$cleanCountry$cleanPhone';
  }

  /// Extracts country code and phone number from a standardized phone number
  /// Example: "+905551234567" -> {"country": "+90", "phone": "5551234567"}
  static Map<String, String> extractPhoneComponents(String standardizedPhone) {
    // Remove any non-digit characters except +
    String cleanPhone = standardizedPhone.replaceAll(RegExp(r'[^\d+]'), '');

    // Find the country code (assume it starts with + and has 1-4 digits)
    RegExp countryCodeRegex = RegExp(r'^\+(\d{1,4})');
    Match? match = countryCodeRegex.firstMatch(cleanPhone);

    if (match != null) {
      String countryCode = '+${match.group(1)}';
      String phoneNumber = cleanPhone.substring(match.end);
      return {'country': countryCode, 'phone': phoneNumber};
    }

    // Fallback: assume no country code
    return {'country': '', 'phone': cleanPhone};
  }

  Future<List<String>> fetchAmenities() async {
    try {
      print("🔍 fetchAmenities çağrıldı");
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/amenities'),
      );
      
      print("🔍 Response status: ${response.statusCode}");
      print("🔍 Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("🔍 Parsed data: $data");

        // Null-safe parsing of amenity names
        final List<String> amenities =
            data.map((e) {
              final name = e['name'];
              if (name == null) {
                print("⚠️ Null amenity name found: $e");
                return 'Unknown Amenity';
              }
              return name.toString();
            }).toList();

        print("🔍 Parsed amenities: $amenities");
        return amenities;
      } else {
        print(
          "❌ fetchAmenities error: ${response.statusCode} - ${response.body}",
        );
        throw Exception('Olanaklar alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ fetchAmenities exception: $e");
      throw Exception('Olanaklar alınırken hata oluştu: $e');
    }
  }
}
