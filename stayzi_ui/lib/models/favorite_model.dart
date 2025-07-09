class Favorite {
  final int id;
  final int userId;

  Favorite({required this.id, required this.userId});

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(id: json['id'], userId: json['user_id']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'user_id': userId};
  }
}

class FavoriteCreate {
  final int userId;

  FavoriteCreate({required this.userId});

  Map<String, dynamic> toJson() {
    return {'user_id': userId};
  }
}
