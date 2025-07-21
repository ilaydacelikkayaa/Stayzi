class Booking {
  final int id;
  final int listingId;
  final int? userId;
  final DateTime startDate;
  final DateTime endDate;
  final int guests;
  final double totalPrice;

  Booking({
    required this.id,
    required this.listingId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.guests,
    required this.totalPrice,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      listingId: json['listing_id'],
      userId: json['user_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      guests: json['guests'],
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'guests': guests,
      'total_price': totalPrice,
    };
  }
}
