class Restaurant {
  final String id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String imageUrl;
  final List<String> categories;
  final bool isOpen;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.imageUrl,
    required this.categories,
    required this.isOpen,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      imageUrl: json['imageUrl'] as String,
      categories: List<String>.from(json['categories'] as List),
      isOpen: json['isOpen'] as bool,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'imageUrl': imageUrl,
      'categories': categories,
      'isOpen': isOpen,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Restaurant copyWith({
    String? name,
    String? description,
    String? address,
    String? phone,
    String? imageUrl,
    List<String>? categories,
    bool? isOpen,
    double? rating,
    int? reviewCount,
  }) {
    return Restaurant(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      isOpen: isOpen ?? this.isOpen,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
} 