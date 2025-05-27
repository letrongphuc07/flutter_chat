enum MenuCategory {
  mainCourse,    // Món chính
  appetizer,     // Khai vị
  dessert,       // Tráng miệng
  beverage,      // Nước uống
  other,         // Khác
}

class MenuItemModel {
  final String menuItemId;
  final String name;
  final String description;
  final double price;
  final MenuCategory category;
  final bool isAvailable;
  final String imageUrl;

  MenuItemModel({
    required this.menuItemId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'description': description,
      'price': price,
      'category': category.toString(),
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
    };
  }

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    return MenuItemModel(
      menuItemId: map['menuItemId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      category: MenuCategory.values.firstWhere(
        (e) => e.toString() == map['category'],
        orElse: () => MenuCategory.other,
      ),
      isAvailable: map['isAvailable'] ?? true,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  MenuItemModel copyWith({
    String? menuItemId,
    String? name,
    String? description,
    double? price,
    MenuCategory? category,
    bool? isAvailable,
    String? imageUrl,
  }) {
    return MenuItemModel(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
} 