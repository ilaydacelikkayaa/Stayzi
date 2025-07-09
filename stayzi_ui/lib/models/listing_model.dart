class Listing {
  final int id;
  final int? userId;
  final String title;
  final String? description;
  final double price;
  final String? location;
  final double? lat;
  final double? lng;
  final String? homeType;
  final List<String>? hostLanguages;
  final List<String>? imageUrls;
  final double averageRating;
  final String? homeRules;
  final DateTime createdAt;

  Listing({
    required this.id,
    this.userId,
    required this.title,
    this.description,
    required this.price,
    this.location,
    this.lat,
    this.lng,
    this.homeType,
    this.hostLanguages,
    this.imageUrls,
    this.averageRating = 0.0,
    this.homeRules,
    required this.createdAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      location: json['location'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      homeType: json['home_type'],
      hostLanguages:
          json['host_languages'] != null
              ? List<String>.from(json['host_languages'])
              : null,
      imageUrls:
          json['image_urls'] != null
              ? List<String>.from(json['image_urls'])
              : null,
      averageRating: json['average_rating']?.toDouble() ?? 0.0,
      homeRules: json['home_rules'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'lat': lat,
      'lng': lng,
      'home_type': homeType,
      'host_languages': hostLanguages,
      'image_urls': imageUrls,
      'average_rating': averageRating,
      'home_rules': homeRules,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ListingCreate {
  final int? userId;
  final String title;
  final String? description;
  final double price;
  final String? location;
  final double? lat;
  final double? lng;
  final String? homeType;
  final List<String>? hostLanguages;
  final List<String>? imageUrls;
  final double averageRating;
  final String? homeRules;

  ListingCreate({
    this.userId,
    required this.title,
    this.description,
    required this.price,
    this.location,
    this.lat,
    this.lng,
    this.homeType,
    this.hostLanguages,
    this.imageUrls,
    this.averageRating = 0.0,
    this.homeRules,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'lat': lat,
      'lng': lng,
      'home_type': homeType,
      'host_languages': hostLanguages,
      'image_urls': imageUrls,
      'average_rating': averageRating,
      'home_rules': homeRules,
    };
  }
}
