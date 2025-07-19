import 'package:stayzi_ui/models/user_model.dart';

class Review {
  final String name;
  final String comment;
  final String date;
  final String profileImage;
  final double rating;
  final User user;
  final DateTime createdAt;

  Review({
    required this.name,
    required this.comment,
    required this.date,
    required this.profileImage,
    required this.rating,
    required this.user,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    print("📥 Gelen review JSON: $json");

    return Review(
      name: json['name']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      profileImage: json['profile_image']?.toString() ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      user:
          json['user'] != null
              ? User.fromJson(json['user'])
              : User(
                id: -1,
                name: '',
                surname: '',
                birthdate: DateTime.now(),
                isActive: true,
              ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'comment': comment,
      'date': date,
      'profile_image': profileImage,
      'rating': rating,
      'user': user.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
