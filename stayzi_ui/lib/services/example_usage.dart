import '../models/favorite_model.dart';
import '../models/listing_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class ExampleUsage {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // ========== AUTHENTICATION EXAMPLES ==========

  Future<void> loginExample() async {
    try {
      // Login with email
      final token = await _apiService.loginWithEmail(
        'user@example.com',
        'password123',
      );

      // Save token to storage
      await _storageService.saveToken(token);

      // Set token in API service
      _apiService.setAuthToken(token.accessToken);

      print('Login successful!');
    } catch (e) {
      print('Login failed: $e');
    }
  }

  Future<void> registerExample() async {
    try {
      // Create user data
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

      // Register user
      final user = await _apiService.registerWithEmail(userData);
      print('User registered: ${user.name} ${user.surname}');
    } catch (e) {
      print('Registration failed: $e');
    }
  }

  // ========== USER PROFILE EXAMPLES ==========

  Future<void> getProfileExample() async {
    try {
      // Get current user profile
      final user = await _apiService.getCurrentUser();
      print('User profile: ${user.name} ${user.surname}');
      print('Email: ${user.email}');
      print('Phone: ${user.phone}');
    } catch (e) {
      print('Failed to get profile: $e');
    }
  }

  Future<void> updateProfileExample() async {
    try {
      // Update user profile
      final updatedUser = await _apiService.updateProfile(
        name: 'Updated Name',
        surname: 'Updated Surname',
        country: 'Updated Country',
      );

      print('Profile updated: ${updatedUser.name} ${updatedUser.surname}');
    } catch (e) {
      print('Failed to update profile: $e');
    }
  }

  // ========== LISTING EXAMPLES ==========

  Future<void> getListingsExample() async {
    try {
      // Get all listings
      final listings = await _apiService.getListings(limit: 10);
      print('Found ${listings.length} listings');

      for (final listing in listings) {
        print('Listing: ${listing.title} - \$${listing.price}');
      }
    } catch (e) {
      print('Failed to get listings: $e');
    }
  }

  Future<void> createListingExample() async {
    try {
      // Create new listing
      final listingData = ListingCreate(
        title: 'Beautiful Apartment',
        description: 'A cozy apartment in the city center',
        price: 150.0,
        location: 'Istanbul, Turkey',
        lat: 41.0082,
        lng: 28.9784,
        homeType: 'Apartment',
        hostLanguages: ['Turkish', 'English'],
        imageUrls: ['image1.jpg', 'image2.jpg'],
        homeRules: 'No smoking, No pets',
      );

      final listing = await _apiService.createListing(listingData);
      print('Listing created: ${listing.title}');
    } catch (e) {
      print('Failed to create listing: $e');
    }
  }

  Future<void> getListingByIdExample() async {
    try {
      // Get specific listing
      final listing = await _apiService.getListingById(1);
      print('Listing details: ${listing.title}');
      print('Price: \$${listing.price}');
      print('Location: ${listing.location}');
    } catch (e) {
      print('Failed to get listing: $e');
    }
  }

  // ========== STORAGE EXAMPLES ==========

  Future<void> storageExample() async {
    try {
      // Check if user is logged in
      final isLoggedIn = await _storageService.isLoggedIn();
      print('Is logged in: $isLoggedIn');

      if (isLoggedIn) {
        // Get stored user
        final user = await _storageService.getUser();
        if (user != null) {
          print('Stored user: ${user.name} ${user.surname}');
        }

        // Get stored token
        final token = await _storageService.getToken();
        if (token != null) {
          print('Stored token: ${token.accessToken}');
        }
      }
    } catch (e) {
      print('Storage error: $e');
    }
  }

  Future<void> logoutExample() async {
    try {
      // Clear all stored data
      await _storageService.logout();

      // Clear token from API service
      _apiService.clearAuthToken();

      print('Logged out successfully');
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // ========== TEST CONNECTION EXAMPLES ==========

  Future<void> testConnectionExample() async {
    try {
      // Test API connection
      final result = await _apiService.testConnection();
      print('API bağlantı testi: $result');

      // Test database connection
      final dbResult = await _apiService.testDatabase();
      print('Veritabanı testi: $dbResult');
    } catch (e) {
      print('Bağlantı testi başarısız: $e');
    }
  }

  // ========== FAVORITE EXAMPLES ==========

  Future<void> getMyFavoritesExample() async {
    try {
      // Get current user's favorites
      final favorites = await _apiService.getMyFavorites(limit: 10);
      print('${favorites.length} favori bulundu');

      for (final favorite in favorites) {
        print('Favori ID: ${favorite.id}, User ID: ${favorite.userId}');
      }
    } catch (e) {
      print('Favoriler getirilemedi: $e');
    }
  }

  Future<void> createFavoriteExample() async {
    try {
      // Create new favorite
      final favoriteData = FavoriteCreate(userId: 1);
      final favorite = await _apiService.createFavorite(favoriteData);
      print('Favori oluşturuldu: ID ${favorite.id}');
    } catch (e) {
      print('Favori oluşturulamadı: $e');
    }
  }
}
