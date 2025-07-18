class Amenity {
  final int id;
  final String name;

  Amenity({required this.id, required this.name});

  Map<String, dynamic> toJson() => {"id": id, "name": name};

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(id: json['id'], name: json['name']);
  }
}
