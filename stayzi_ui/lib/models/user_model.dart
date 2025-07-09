class User {
  final int id;
  final String? email;
  final String name;
  final String surname;
  final DateTime birthdate;
  final String? phone;
  final String? country;
  final String? profileImage;
  final bool isActive;
  final DateTime? createdAt;

  User({
    required this.id,
    this.email,
    required this.name,
    required this.surname,
    required this.birthdate,
    this.phone,
    this.country,
    this.profileImage,
    this.isActive = true,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      surname: json['surname'],
      birthdate: DateTime.parse(json['birthdate']),
      phone: json['phone'],
      country: json['country'],
      profileImage: json['profile_image'],
      isActive: json['is_active'] ?? true,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'surname': surname,
      'birthdate': birthdate.toIso8601String().split('T')[0],
      'phone': phone,
      'country': country,
      'profile_image': profileImage,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class UserCreate {
  final String email;
  final String name;
  final String surname;
  final DateTime birthdate;
  final String phone;
  final String country;
  final String profileImage;
  final bool isActive;
  final String password;
  final DateTime? createdAt;

  UserCreate({
    required this.email,
    required this.name,
    required this.surname,
    required this.birthdate,
    required this.phone,
    required this.country,
    required this.profileImage,
    this.isActive = true,
    required this.password,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'surname': surname,
      'birthdate': birthdate.toIso8601String().split('T')[0],
      'phone': phone,
      'country': country,
      'profile_image': profileImage,
      'is_active': isActive,
      'password': password,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class UserUpdate {
  final String? email;
  final String? name;
  final String? surname;
  final DateTime? birthdate;
  final String? phone;
  final String? country;
  final String? profileImage;
  final bool? isActive;

  UserUpdate({
    this.email,
    this.name,
    this.surname,
    this.birthdate,
    this.phone,
    this.country,
    this.profileImage,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (email != null) data['email'] = email;
    if (name != null) data['name'] = name;
    if (surname != null) data['surname'] = surname;
    if (birthdate != null) {
      data['birthdate'] = birthdate!.toIso8601String().split('T')[0];
    }
    if (phone != null) data['phone'] = phone;
    if (country != null) data['country'] = country;
    if (profileImage != null) data['profile_image'] = profileImage;
    if (isActive != null) data['is_active'] = isActive;
    return data;
  }
}

class PhoneRegister {
  final String name;
  final String surname;
  final DateTime birthdate;
  final String phone;
  final String password;

  PhoneRegister({
    required this.name,
    required this.surname,
    required this.birthdate,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'birthdate': birthdate.toIso8601String().split('T')[0],
      'phone': phone,
      'password': password,
    };
  }
}
