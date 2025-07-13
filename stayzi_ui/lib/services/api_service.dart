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
  }

  // Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  // Get headers with or without authentication
  Map<String, String> _getHeaders({bool requiresAuth = false}) {
    if (requiresAuth && _authToken != null) {
      return ApiConstants.authHeaders(_authToken!);
    }
    return ApiConstants.defaultHeaders;
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
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

  // Deactivate account
  Future<Map<String, dynamic>> deactivateAccount() async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deactivateAccount}'),
        headers: _getHeaders(requiresAuth: true),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to deactivate account: $e');
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

  // Create new listing
  Future<Listing> createListing(ListingCreate listingData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createListing}'),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode(listingData.toJson()),
      );
      final data = _handleResponse(response);
      return Listing.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create listing: $e');
    }
  }

  // Update listing
  Future<Listing> updateListing(
    int listingId,
    ListingCreate listingData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.updateListing}$listingId',
        ),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode(listingData.toJson()),
      );
      final data = _handleResponse(response);
      return Listing.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update listing: $e');
    }
  }

  // Delete listing
  Future<Listing> deleteListing(int listingId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.deleteListing}$listingId',
        ),
        headers: _getHeaders(requiresAuth: true),
      );
      final data = _handleResponse(response);
      return Listing.fromJson(data);
    } catch (e) {
      throw Exception('Failed to delete listing: $e');
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
}
