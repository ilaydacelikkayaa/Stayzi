class Favorite {
  final int id;
  final int userId;
  final int listingId;
  final String? listName;
  final DateTime? createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.listingId,
    this.listName,
    this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      userId: json['user_id'],
      listingId: json['listing_id'],
      listName: json['list_name'],
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
      'list_name': listName,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class FavoriteCreate {
  final int listingId;
  final String? listName;
  final int? userId; // Optional, will be set from current user if not provided

  FavoriteCreate({required this.listingId, this.listName, this.userId});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'listing_id': listingId};
    if (listName != null) {
      data['list_name'] = listName;
    }
    if (userId != null) {
      data['user_id'] = userId;
    }
    return data;
  }
}
