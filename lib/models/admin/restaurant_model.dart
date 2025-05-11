class RestaurantModel {
  final String id;
  final String name;
  final String address;
  final String? imageUrl;
  final String ownerId;
  final bool isActive;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.address,
    this.imageUrl,
    required this.ownerId,
    this.isActive = true,
  });

  factory RestaurantModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return RestaurantModel(
      id: docId,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'],
      ownerId: data['ownerId'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'isActive': isActive,
    };
  }

  RestaurantModel copyWith({
    String? name,
    String? address,
    String? imageUrl,
    String? ownerId,
    bool? isActive,
  }) {
    return RestaurantModel(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      isActive: isActive ?? this.isActive,
    );
  }
} 