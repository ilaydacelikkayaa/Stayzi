class Favorite {
  final int id;
  final int userId;
  final int listingId;
  final DateTime? createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.listingId,
    this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      userId: json['user_id'],
      listingId: json['listing_id'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'listing_id': listingId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class FavoriteCreate {
  final int listingId;
  final int? userId; // Optional, will be set from current user if not provided

  FavoriteCreate({required this.listingId, this.userId});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'listing_id': listingId};
    if (userId != null) {
      data['user_id'] = userId;
    }
    return data;
  }
}
