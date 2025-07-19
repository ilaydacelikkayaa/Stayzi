import 'user_model.dart';

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
  final List<String>? amenities;
  final int? roomCount;
  final int? bedCount;
  final int? bathroomCount;
  final int? reviewCount;
  final int? allowEvents;
  final int? allowSmoking;
  final int? allowCommercialPhoto;
  final int? maxGuests;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final User? user;

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
    this.roomCount,
    this.bedCount,
    this.bathroomCount,
    this.reviewCount,
    this.allowEvents,
    this.allowSmoking,
    this.allowCommercialPhoto,
    this.maxGuests,
    required this.createdAt,
    this.updatedAt,
    this.user,
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
      capacity: json['capacity'],
      amenities:
          json['amenities'] != null
              ? List<String>.from(json['amenities'])
              : null,
      roomCount: json['room_count'],
      bedCount: json['bed_count'],
      bathroomCount: json['bathroom_count'],
      reviewCount: json['review_count'],
      allowEvents: json['allow_events'],
      allowSmoking: json['allow_smoking'],
      allowCommercialPhoto: json['allow_commercial_photo'],
      maxGuests: json['max_guests'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
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
      'room_count': roomCount,
      'bed_count': bedCount,
      'bathroom_count': bathroomCount,
      'review_count': reviewCount,
      'allow_events': allowEvents,
      'allow_smoking': allowSmoking,
      'allow_commercial_photo': allowCommercialPhoto,
      'max_guests': maxGuests,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
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
  final List<String>? amenities;
  final int? allowEvents;
  final int? allowSmoking;
  final int? allowCommercialPhoto;
  final int? maxGuests;

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
    this.allowEvents,
    this.allowSmoking,
    this.allowCommercialPhoto,
    this.maxGuests,
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
      'amenities': amenities,
      'allow_events': allowEvents,
      'allow_smoking': allowSmoking,
      'allow_commercial_photo': allowCommercialPhoto,
      'max_guests': maxGuests,
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
  final int? allowEvents;
  final int? allowSmoking;
  final int? allowCommercialPhoto;
  final int? maxGuests;

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
    this.allowEvents,
    this.allowSmoking,
    this.allowCommercialPhoto,
    this.maxGuests,
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
    if (allowEvents != null) data['allow_events'] = allowEvents;
    if (allowSmoking != null) data['allow_smoking'] = allowSmoking;
    if (allowCommercialPhoto != null)
      data['allow_commercial_photo'] = allowCommercialPhoto;
    if (maxGuests != null) data['max_guests'] = maxGuests;
    return data;
  }
}
