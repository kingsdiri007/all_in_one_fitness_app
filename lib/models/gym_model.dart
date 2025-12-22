class GymModel {
  final int id;
  final String name;
  final String address;
  final String distance;
  final String? phone;
  final double rating;
  final List<String> amenities;

  GymModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    this.phone,
    required this.rating,
    required this.amenities,
  });

  // Factory constructor to create GymModel from JSON
  factory GymModel.fromJson(Map<String, dynamic> json) {
    return GymModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      distance: json['distance'] ?? '',
      phone: json['phone'],
      rating: (json['rating'] ?? 0).toDouble(),
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : [],
    );
  }

  // Convert GymModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'distance': distance,
      'phone': phone,
      'rating': rating,
      'amenities': amenities,
    };
  }
}
