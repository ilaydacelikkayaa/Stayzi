import 'package:stayzi_ui/models/amenity_model.dart';
import 'package:stayzi_ui/models/user_model.dart';

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
  final int? capacity;
  final List<Amenity>? amenities;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final User? host;

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
    this.capacity,
    this.amenities,
    required this.createdAt,
    this.updatedAt,
    this.host,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    print("👤 Gelen HOST JSON: ${json['host']}");
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
      capacity: json['capacity'],
      amenities:
          json['amenities'] != null
              ? List<Amenity>.from(
                json['amenities'].map((e) => Amenity.fromJson(e)),
              )
              : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      host: json['host'] != null ? User.fromJson(json['host']) : null,
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
      'capacity': capacity,
      'amenities': amenities,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'host': host?.toJson(),
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
  final int? capacity;
  final List<Amenity>? amenities;

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
    this.capacity,
    this.amenities,
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
      'capacity': capacity,
      'amenities': amenities?.map((e) => e.toJson()).toList(),
    };
  }
}

class ListingUpdate {
  final String? title;
  final String? description;
  final double? price;
  final String? location;
  final double? lat;
  final double? lng;
  final String? homeType;
  final List<String>? hostLanguages;
  final String? homeRules;
  final int? capacity;
  final List<String>? amenities;

  ListingUpdate({
    this.title,
    this.description,
    this.price,
    this.location,
    this.lat,
    this.lng,
    this.homeType,
    this.hostLanguages,
    this.homeRules,
    this.capacity,
    this.amenities,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (location != null) data['location'] = location;
    if (lat != null) data['lat'] = lat;
    if (lng != null) data['lng'] = lng;
    if (homeType != null) data['home_type'] = homeType;
    if (hostLanguages != null) data['host_languages'] = hostLanguages;
    if (homeRules != null) data['home_rules'] = homeRules;
    if (capacity != null) data['capacity'] = capacity;
    if (amenities != null) data['amenities'] = amenities;
    return data;
  }
}
