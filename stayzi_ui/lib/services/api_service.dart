import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

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
    print("DEBUG: _handleResponse çağrıldı, body: " + response.body);
    final data = json.decode(response.body);
    if (data is Map && data['detail'] != null) {
      throw Exception(data['detail']);
    }
    if (data is Map || data is List) {
      return data;
    }
    throw Exception(
      'Beklenmeyen response tipi: ' + data.runtimeType.toString(),
    );
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
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEmail}'),
        headers: _getHeaders(),
        body: {'username': email, 'password': password},
      );
      final data = _handleResponse(response);
      return Token.fromJson(data);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Login with phone
  Future<Token> loginWithPhone(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginPhone}'),
        headers: {'Content-Type': 'application/json'}, // direkt sabit yaz
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      final data = _handleResponse(response);
      final token = Token.fromJson(data);
      setAuthToken(token.accessToken);

      print("📲 Giriş yapan kullanıcının token'ı: ${token.accessToken}");

      return Token.fromJson(data);
    } catch (e) {
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

      // Add form fields
      if (name != null) request.fields['name'] = name;
      if (surname != null) request.fields['surname'] = surname;
      if (email != null) request.fields['email'] = email;
      if (birthdate != null) {
        request.fields['birthdate'] = birthdate.toIso8601String().split('T')[0];
      }
      if (country != null) request.fields['country'] = country;

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
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userById}$userId'),
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
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.listings}?skip=$skip&limit=$limit',
        ),
        headers: _getHeaders(),
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
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.listingById}$listingId',
        ),
        headers: _getHeaders(),
      );
      final data = _handleResponse(response);
      return Listing.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get listing: $e');
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
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.myFavorites}?skip=$skip&limit=$limit',
        ),
        headers: _getHeaders(requiresAuth: true),
      );
      final data = _handleResponse(response);
      return (data as List).map((json) => Favorite.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get my favorites: $e');
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
  Future<List<Listing>> getMyListings({String? token}) async {
    print('getMyListings çağrıldı, token: ' + (token ?? 'YOK'));
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/listings/my-listings'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('getMyListings response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('getMyListings tamamlandı, ilan sayısı: ${data.length}');
      return data.map((json) => Listing.fromJson(json)).toList();
    } else {
      print('getMyListings hata: ${response.body}');
      throw Exception('İlanlar yüklenemedi');
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
    List<String>? amenities,
    File? photo,
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

      if (hostLanguages != null) {
        request.fields['host_languages'] = json.encode(hostLanguages);
      }

      if (amenities != null) {
        request.fields['amenities'] = json.encode(amenities);
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

  // Update listing with photo
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
    List<String>? amenities,
    File? photo,
  }) async {
    try {
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

      if (hostLanguages != null) {
        request.fields['host_languages'] = json.encode(hostLanguages);
      }

      if (amenities != null) {
        request.fields['amenities'] = json.encode(amenities);
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
      throw Exception('İlan güncellenemedi: $e');
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
}
